---
title: "The Firestore Write-Only Trap"
description: "Our email waitlist worked locally, compiled fine, deployed fine. Then Firestore threw 'Missing or insufficient permissions' because our duplicate check was secretly reading."
pubDate: 2026-03-08
tags: ["Firebase", "Firestore", "Debugging", "BuildInPublic"]
readingTime: "6 min read"
draft: false
---

We needed an email waitlist for our app and a subscribe form for the blog. Simple stuff. Collect emails in Firestore, don't let anyone read them from the client. Write-only.

Took about an hour to build. Compiled. Deployed. Then production said no.

## The Setup

The app already uses Firebase, so Firestore was the obvious choice. No newsletter, no Beehiiv, no Mailchimp. We just want to collect emails and look at them later in the Firebase Console.

I wrote a `subscribeEmail` function. Two collections: `waitlist` for app launch signups, `blog_subscribers` for blog readers. Pretty standard:

```typescript
import { initializeApp, getApps } from "firebase/app";
import {
  getFirestore,
  collection,
  addDoc,
  query,
  where,
  getDocs,
  serverTimestamp,
} from "firebase/firestore";

export async function subscribeEmail(
  collectionName: "waitlist" | "blog_subscribers",
  email: string
): Promise<{ success: boolean; message: string }> {
  const normalized = email.toLowerCase().trim();

  const q = query(
    collection(db, collectionName),
    where("email", "==", normalized)
  );
  const existing = await getDocs(q);

  if (!existing.empty) {
    return { success: true, message: "You're already on the list!" };
  }

  await addDoc(collection(db, collectionName), {
    email: normalized,
    created_at: serverTimestamp(),
  });

  return { success: true, message: "You're on the list!" };
}
```

And the security rules, write-only:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /waitlist/{doc} {
      allow create: if request.resource.data.keys().hasOnly(['email', 'created_at'])
                    && request.resource.data.email is string;
      allow read, update, delete: if false;
    }
    match /blog_subscribers/{doc} {
      allow create: if request.resource.data.keys().hasOnly(['email', 'created_at'])
                    && request.resource.data.email is string;
      allow read, update, delete: if false;
    }
  }
}
```

Clean. Validates that documents only contain `email` (must be a string) and `created_at`. No reads, no updates, no deletes from the client. Admins use the Firebase Console.

Build passed. TypeScript happy. Deployed to Vercel. Done, right?

## Error Code 7

First signup attempt in production:

```json
{
  "targetChange": {
    "targetChangeType": "REMOVE",
    "targetIds": [2],
    "cause": {
      "code": 7,
      "message": "Missing or insufficient permissions."
    }
  }
}
```

Code 7. `PERMISSION_DENIED`.

My first instinct was the rules hadn't propagated. Firebase says rules can take up to 10 minutes. I waited. Still broken.

Then I looked at the network tab. The failing request wasn't a write. It was a `Listen/channel` request — Firestore's real-time listener. That's a read.

## The Duplicate Check

Go back and read the function. See it?

```typescript
const q = query(
  collection(db, collectionName),
  where("email", "==", normalized)
);
const existing = await getDocs(q);
```

`getDocs` is a read operation. It queries the collection looking for matching emails. I wrote security rules that say `allow read: if false`. The code was doing exactly what the rules said it couldn't do.

This pattern is everywhere. Check for duplicates, then insert. It's the obvious approach. But if your security model is write-only, you just broke it.

What makes this annoying is the feedback loop. TypeScript doesn't know about your Firestore rules. The Firebase emulator might have different rules. Locally everything works. It only blows up in production with real rules deployed.

## The Fix

Use the email itself as the document ID. Then use `setDoc` instead of `addDoc`. No read needed. If someone signs up twice, it overwrites the same document. Same email, same doc, no duplicates, no reads.

```typescript
import {
  getFirestore,
  doc,
  setDoc,
  serverTimestamp,
} from "firebase/firestore";

export async function subscribeEmail(
  collectionName: "waitlist" | "blog_subscribers",
  email: string
): Promise<{ success: boolean; message: string }> {
  const normalized = email.toLowerCase().trim();

  await setDoc(doc(db, collectionName, normalized), {
    email: normalized,
    created_at: serverTimestamp(),
  });

  return { success: true, message: "You're on the list!" };
}
```

Nine lines instead of twenty. No `query`, no `where`, no `getDocs`, no `collection` import for querying. Just write.

The security rules need a small update because `setDoc` on an existing doc is an update, not a create:

```
allow create, update: if request.resource.data.keys().hasOnly(['email', 'created_at'])
                      && request.resource.data.email is string;
allow read, delete: if false;
```

That's it. Still write-only. Still validates the schema. But now the client can overwrite its own signup without needing to read first.

## It's Also a Better Data Model

Forget the permissions thing for a second.

With `addDoc`, Firestore generates a random ID. Your collection could look like:

```
waitlist/
  abc123 → { email: "foo@bar.com", created_at: ... }
  def456 → { email: "foo@bar.com", created_at: ... }
  ghi789 → { email: "baz@bar.com", created_at: ... }
```

Two entries for the same email. Your duplicate check was supposed to prevent this, but if two requests come in at the same time (double-click, slow connection, retry), you get dupes anyway. The read-then-write isn't atomic.

With `setDoc` and email as the ID:

```
waitlist/
  foo@bar.com → { email: "foo@bar.com", created_at: ... }
  baz@bar.com → { email: "baz@bar.com", created_at: ... }
```

Duplicates are structurally impossible. The document ID enforces uniqueness. No race conditions. No reads.

## The NEXT_PUBLIC_ Thing

Quick sidebar because this comes up every time someone sees Firebase config in client code.

```
NEXT_PUBLIC_FIREBASE_API_KEY=AIza...
NEXT_PUBLIC_FIREBASE_PROJECT_ID=my-app-12345
```

"You're leaking your API key!" No. Firebase client config is designed to be public. It ships in every Firebase web app's HTML. Google's own docs say so. The API key identifies your project. It doesn't grant access to anything.

Your actual security is the Firestore rules. That's the whole point of this post. The rules are the lock. The config is the address.

If someone has your Firebase config, all they can do is what your rules allow. In our case: create a document with an email string and a timestamp. That's it. They can't read, can't delete, can't write anything else.

## Audit Your Reads

If you're writing Firestore rules with `allow read: if false`, grep your codebase for `getDocs`, `getDoc`, `onSnapshot`, and `query`. All reads. All will blow up.

And if you find yourself needing a read to make a write work, that's usually a data model problem, not a rules problem. Natural keys as document IDs fix most of it.

---

*Building [Aanvi](https://aanvi.app) in public. Find me on [X @AKritix](https://x.com/AKritix).*

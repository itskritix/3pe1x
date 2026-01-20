# Astro Starter Kit: Minimal

```sh
npm create astro@latest -- --template minimal
```

> 🧑‍🚀 **Seasoned astronaut?** Delete this file. Have fun!

## 🚀 Project Structure

Inside of your Astro project, you'll see the following folders and files:

```text
/
├── public/
├── src/
│   └── pages/
│       └── index.astro
└── package.json
```

Astro looks for `.astro` or `.md` files in the `src/pages/` directory. Each page is exposed as a route based on its file name.

There's nothing special about `src/components/`, but that's where we like to put any Astro/React/Vue/Svelte/Preact components.

Any static assets, like images, can be placed in the `public/` directory.

## 🧞 Commands

All commands are run from the root of the project, from a terminal:

| Command                   | Action                                           |
| :------------------------ | :----------------------------------------------- |
| `npm install`             | Installs dependencies                            |
| `npm run dev`             | Starts local dev server at `localhost:4321`      |
| `npm run build`           | Build your production site to `./dist/`          |
| `npm run preview`         | Preview your build locally, before deploying     |
| `npm run astro ...`       | Run CLI commands like `astro add`, `astro check` |
| `npm run astro -- --help` | Get help using the Astro CLI                     |

## 🚀 Deployment

This project is deployed on [Vercel](https://vercel.com).

**Live Site:** https://www.3pe1x.com

### Prerequisites

1. Install the Vercel CLI:
   ```sh
   npm install -g vercel
   ```

2. Login to Vercel:
   ```sh
   vercel login
   ```

### Deploy to Production

Run the following command from the project root:

```sh
vercel --prod
```

This will:
- Build the Astro project
- Upload the static files to Vercel
- Deploy to production

### Deploy Preview

For a preview deployment (staging):

```sh
vercel
```

### Environment Variables

No environment variables are required for this static site.

### Build Settings (Auto-detected)

Vercel automatically detects the Astro framework and uses:
- **Build Command:** `npm run build`
- **Output Directory:** `dist`
- **Install Command:** `npm install`

## 👀 Want to learn more?

Feel free to check [our documentation](https://docs.astro.build) or jump into our [Discord server](https://astro.build/chat).

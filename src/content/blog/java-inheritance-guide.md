---
title: "Maximise Your Java Development with Inheritance: A Comprehensive Guide"
description: "A comprehensive guide to understanding and implementing inheritance in Java - one of the four major pillars of OOP."
pubDate: 2023-02-11
tags: ["Java", "OOP", "Inheritance"]
readingTime: "8 min read"
heroImage: "/blog/inheritance-3.png"
draft: false
---

## Introduction to Java Inheritance

Java is an object-oriented programming language. As OOP, it has four major pillars and inheritance is one of those. What exactly is inheritance in Java, then? We all know the meaning of inheritance (Transmission of genetic qualities from parent to offspring).

Inheritance is the process of making a new class from an old class by inheriting all of the properties (methods/Data members) from the old class. In other words, new classes are created based on existing classes. Is-A Relation is the name of the relationship between the new class (child) and the old class (parent).

![Inheritance Diagram](/blog/inheritance-1.png)

In Java naming convention: Old class = Super class. New Class = Subclass

**Syntax:**

```java
public class subClassName extends SuperClassName
{
  // Implementation
}
```

## Importance of Inheritance in Java

1. One of the important reasons for Java is **reusability of code**. It is possible because of inheritance. It allows us to write one class and inherit its properties into subclasses. (Person is super class, and it has name, gender, and age, just as we learn these qualities in student classes, plus some additional attributes like roll number/marks.) This saves time and effort and reduces the amount of code that needs to be written, tested, and maintained.

2. **Improving Code Maintenance** - if we make any change in super class, it automatically propagates all changes into subclass.

3. **Hierarchical order** - This makes the codebase easier to manage and comprehend, especially for complex projects with many classes.

## Types of Inheritance

![Types of Inheritance](/blog/inheritance-2.png)

1. **Single Inheritance**: As shown above in the diagram, Student is derived from only one class - this is called single inheritance. In simple words: when a subclass is derived from one superclass.

2. **Multiple Inheritance**: Multiple Inheritance means inherited classes have more than one superclass. It is not directly supported in Java; it is achieved by using interfaces. (Diamond Problem)

3. **Hybrid Inheritance**: Hybrid means combining any two or more types of inheritance. A subclass, for example, could inherit from multiple superclasses while also having its subclasses.

4. **Multi-level Inheritance**: Multilevel inheritance means inheriting a superclass from other superclasses.

## How Java Inheritance Works

### Extending Class

To inherit a super class in a subclass, the **"extends"** keyword is used:

```java
public class Employee
{
  private String name;
  private int age;
  private String gender;
  // fields and methods
}

public class Manager extends Employee {
   private int salary;
   private int ManagerId;
   // additional fields and methods
}
// In this Example Employee is SuperClass and Manager is Subclass
```

### Method Override

A new implementation of an inherited method in a Subclass is called Method Overriding:

```java
public class Employee {
    public String toString() {
        // Implementation
    }
}

public class Manager extends Employee {
    @Override
    public String toString() {
        // New Implementation
    }
}
```

### Use of the "super" Keyword

We can refer to the SuperClass Constructor using the super keyword:

```java
public class Employee {
    private String name;
    private int age;

    // Constructor
    public Employee(String name, int age) {
        this.name = name;
        this.age = age;
    }

    public String toString() {
        // Implementation
    }
}

public class Manager extends Employee {

    private double salary;
    private float rating;

    // Constructor
    public Manager(String name, int age, double salary, float rating) {
        super(name, age); // this calls Employee(name, age)
        this.salary = salary;
        this.rating = rating;
    }

    @Override
    public String toString() {
        // New Implementation
    }
}
```

## Common Mistakes to Avoid With Inheritance

1. **Overriding Method Incompletely**: Overriding a method with different parameters and return type leads to compile time error.

2. **Overriding Private methods**: Subclasses do not inherit private methods. Attempting to override results in a compile-time error.

## Conclusion

SubClass is SuperClass and some things more (additional state and methods) and something modified (overloading).

It allows for code reuse and contributes to creating a more ordered and efficient codebase.

![Inheritance Concept](/blog/inheritance-3.png)

> My Final Thoughts on Java Inheritance

Inheritance enables us to write less code and reuse code. It saves our effort and makes our life easier as developers. I love this feature.

## Practice Questions

**Q1.** Create a Shape superclass and use it to create a Cylinder subclass and a Rectangle subclass in Java to demonstrate inheritance. The Cylinder and Rectangle classes should have methods for calculating area and volume, as well as property getters and setters.

```java
class Shape {
  private double area;

  public Shape() {}

  public double getArea() {
    return this.area;
  }

  public void setArea(double area) {
    this.area = area;
  }
}

class Cylinder extends Shape {
  private double height;
  private double radius;

  public Cylinder(double height, double radius) {
    this.height = height;
    this.radius = radius;
  }

  public double getHeight() {
    return this.height;
  }

  public void setHeight(double height) {
    this.height = height;
  }

  public double getRadius() {
    return this.radius;
  }

  public void setRadius(double radius) {
    this.radius = radius;
  }

  public double calculateArea() {
    double baseArea = Math.PI * this.radius * this.radius;
    double sideArea = 2 * Math.PI * this.radius * this.height;
    this.setArea(2 * baseArea + sideArea);
    return this.getArea();
  }

  public double calculateVolume() {
    return Math.PI * this.radius * this.radius * this.height;
  }
}

class Rectangle extends Shape {
  private double length;
  private double width;

  public Rectangle(double length, double width) {
    this.length = length;
    this.width = width;
  }

  public double getLength() {
    return this.length;
  }

  public void setLength(double length) {
    this.length = length;
  }

  public double getWidth() {
    return this.width;
  }

  public void setWidth(double width) {
    this.width = width;
  }

  public double calculateArea() {
    this.setArea(this.length * this.width);
    return this.getArea();
  }

  public double calculateVolume() {
    return 0;
  }
}
```

**Q2.** Make an Animal base class that has public getter and setter methods for the private member variables name and age. Create the Dog and Cat subclasses, which will both inherit from Animal and have new attributes with getter and setter methods.

---

*Originally published on [Medium](https://kritix.medium.com)*

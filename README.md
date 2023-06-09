# Mantis Programming Language

![Mantis Shrimp](images/mantis.jpeg)

Mantis is a statically typed, high-performance programming language designed for machine learning and high-performance computing.
It compiles to WebAssembly, allowing your code to run anywhere WebAssembly is supported, including web browsers and server environments.

## Getting Started

### Installation

#### Prerequisites

Before installing Mantis, please ensure that you have installed [zig 0.11.0-dev.3859+88284c124](https://ziglang.org/) and [wasmer](https://wasmer.io/).
Zig is a fast and reliable language that we've used to develop Mantis's compiler,
and Wasmer is the WebAssembly runtime that Mantis relies on for executing your code.

#### Compiling From Source

Follow the steps below to compile Mantis from its source code:

1. Clone the repository:

First, you'll need to clone the Mantis repository from GitHub. You can do this using Git with the following command:

```bash
git clone git@github.com:adam-r-kowalski/mantis.git
```

This command creates a copy of the Mantis repository on your local machine.

2. Navigate into the repository directory:

Use the following command to navigate into the directory of the repository you just cloned:

```bash
cd mantis
```

3. Run the tests:

Before proceeding, it's a good idea to run the Mantis tests to ensure that everything is functioning as expected. You can do this with the following command:

```bash
zig build test
```

This command runs the tests and outputs the results. If all tests pass, you're good to proceed.

4. Build the compiler:

Once the tests have passed, you can build the Mantis compiler. Use the following command to do this:

```bash
zig build
```

This command builds the Mantis compiler from the source code.

5. Add the compiler to your PATH:

The final step is to add the Mantis compiler to your PATH so that you can use it from any location on your system. Here is how you can do it:

```bash
export PATH=$PATH:`pwd`/zig-out/bin/
```

This command adds the directory containing the Mantis compiler to your system's PATH.

Now, you have Mantis installed on your system, and you're ready to start coding!

### Running a Mantis program

```bash
mantis source.mantis
```

This will compile your Mantis code into web assembly and then execute it using the wasmer runtime.
To see the generated wat code add `--wat` to the compile command.

```bash
mantis source.mantis --wat
```

Look at the code in the `examples` folder for inspiration.
This compiler is a work in progress so expect bugs and incomplete features.
You should NOT be using this in production yet.
However, code in the examples folder should compile and run.

### Your first Mantis program

Mantis has a straightforward syntax that is easy to read and write.
Here is a simple Mantis program that defines a function to calculate the square of a number:

```mantis
square = (x: i32) i32 { x^2 }

test("function calls", () {
    assert(square(1) == 1)
    assert(square(2) == 4)
    assert(square(3) == 9)
})
```

This program defines a function `square` and a set of tests to verify its behavior.

## Basic Constructs

### Comments

In Mantis, you can insert comments in your code to provide explanations or annotations.
Comments are ignored by the compiler and do not affect the execution of the program.
You can add a comment by starting the line with a hash (`#`).

Here's an example:

```mantis
# This is a single line comment

square = (x: i32) i32 {
    # This function calculates the square of a number
    x^2
}

# You can also place comments at the end of a line

sum = (xs: vec[i32]) i32 { xs.fold(0, +) } # Here we calculate the sum of an array
```

### Functions

In Mantis, you define a function using the `fn` keyword, followed by a list of parameters and their types, the return type, and then the function body.

```mantis
max = (x: i32, y: i32) i32 {
    if x > y { x } else { y }
}

min = (x: i32, y: i32) i32 {
    if x < y { x } else { y }
}

test("if else", () {
    assert(max(5, 3) == 5)
    assert(min(5, 3) == 3)
})
```

This is a function `max` that takes two parameters, `x` and `y`, and returns the greater of the two.

### Control Structures

Mantis supports conditional logic with `if`, `else if` and `else` expressions.

```mantis
clamp = (value: i32, low: i32, high: i32) i32 {
    if value < low { low }
    else if value > high { high }
    else { value }
}

test("multi arm if", () {
    assert(clamp(1, 3, 5) == 3)
    assert(clamp(7, 3, 5) == 5)
    assert(clamp(4, 3, 5) == 4)
})
```

This `clamp` function ensures that a value stays within a specific range.

### Named Parameters

Mantis supports named parameters, which can improve the readability of your code. Here is an example of using named parameters:

```mantis
test("named parameters", () {
    assert(clamp(value=1, low=3, high=5) == 3)
    assert(clamp(value=7, low=3, high=5) == 5)
    assert(clamp(value=4, low=3, high=5) == 4)
})
```

In this example, we are calling the `clamp` function with named parameters `value`, `low`, and `high`.
This makes it clear what each parameter represents, which can be particularly helpful when dealing with
functions that have many parameters or when the purpose of a parameter isn't immediately clear from its name.

In this example, we are calling the `clamp` function using the dot syntax on an integer value.
This can make your code more readable by clearly associating a function with the data it operates on.

### Pattern Matching

Mantis supports pattern matching, which is a way of checking a given sequence of tokens for the presence of the constituents of some pattern.
It's a powerful tool for working with complex data structures.

```mantis
# pattern matching is done with `match expression`
sum = (xs: vec[i32]) i32 {
    match xs {
        [] { 0 }
        [x, ...xs] { x + sum(xs) }
    }
}

test("sum", () {
    assert(sum([1, 2, 3]) == 6)
})
```

In the above code, `sum` is a function that takes a list of integers and returns the sum of all elements in the list.
The `match xs` construct is used for pattern matching. If the list is empty (`[]`), the function returns `0`.
If the list has at least one element (`[x, ...xs]`), the function returns the sum of the first element and the
result of the recursive call to `sum` on the rest of the list.

### Destructuring

Destructuring in Mantis allows you to bind a set of variables to a corresponding set of values provided in a complex data structure,
such as a struct or array. It provides a convenient way to extract multiple values from data stored in (possibly nested) objects and arrays.

For example, consider the `Square` struct and the implementation of `Shape` interface for it:

```mantis
Square = struct {
    width: f32,
    height: f32
}

area = ({width, height}: Square) f32 {
    width * height
}

test("area of square", () {
    assert(area({ width: 10, height: 5 }) == 50)
})
```

In the `area` function for `Square`, `{width, height}` is a destructuring assignment:
it binds the variables `width` and `height` to the respective values in the passed `Square` object.

Another example of destructuring can be found in array pattern matching:

```mantis
# pattern matching with destructuring
sum = (xs: vec[i32]) i32 {
    match xs {
        [] { 0 }
        [x, ...rest] { x + sum(rest) }
    }
}
```

In this function, `[x, ...rest]` destructures the array `xs`, binding the variable `x` to the
first element of the array and `rest` to the rest of the array.

Destructuring can make your code more readable and less error-prone by avoiding manual indexing and temporary variables.

### Shadowing

Shadowing in Mantis allows you to declare a new variable with the same name as a previously declared variable.
The new variable shadows the previous one within its scope, meaning the previous variable cannot be accessed.
This is not an error in Mantis; it's a feature of the language.

Here's an example:

```mantis
x = 5

if true {
    x = 10 # This x shadows the x declared outside the if block
    log(x) # This will print 10
}

log(x) # This will print 5 because the shadowed x was only valid within the if block
```

In this example, `x` is shadowed within the `if` block. The `log` function within the block prints the shadowed `x`,
while the one outside the block prints the original `x`.

Shadowing can be useful when you want to reuse variable names, but be careful, as it can lead to confusion if not used judiciously.

### Importing from other files

Mantis supports importing other files and calling functions in them

```mantis
# math.mantis
pi: f64 = 3.14
```

```mantis
# circle.mantis
math = import("math.mantis")

Circle = struct {
    radius: f64
}

area = ({radius}: Circle) f64 {
    math.pi * radius ^ 2
}

test("area of a circle", () {
    assert(area({radius: 10}) == 314)
})
```

### Foreign Function Interface

Mantis supports importing and exporting functions from the host environment.

```mantis
# Import a function from the host
log = foreign_import("console", "log", (x: str) void)

# Export a function to the host
foreign_export("double", (x: i32) i32 { x * 2 })

# call the log function from Mantis
start = () void {
    log("hello world")
}
```

In this example, the `log` function is imported from the host's console, and the `double` function is exported for use by the host.

[WASI](https://wasi.dev/) stands for WebAssembly System Interface. It's an API designed by the Wasmtime project that provides access to
several operating-system-like features, including files and filesystems, Berkeley sockets, clocks, and random numbers,
that we'll be proposing for standardization.

It's designed to be independent of browsers, so it doesn't depend on Web APIs or JS, and isn't limited by the need to be compatible with JS.
And it has integrated capability-based security, so it extends WebAssembly's characteristic sandboxing to include I/O.

It is a first class citizen in Mantis and by targeting this API you can ensure that your programs work across as many platforms as possible.

```mantis
fd_write = foreign_import(
    "wasi_unstable",
    "fd_write",
    (fd: i32, iovs: str, iovs_len: i32, mut nwritten: i32) i32
)

stdout: i32 = 1

print = (text: str) void {
    mut nwritten: i32 = undefined
    _ = stdout.fd_write(text, 1, mut nwritten)
}

start = () void {
    print("Hello, World!\n")
    print("Goodbye!")
}
```

### Built-in Data Structures and Algorithms

Mantis includes built-in support for arrays and powerful operations over them.

```mantis
# Create an array
xs = [1, 2, 3, 4, 5]

# Compute the sum of an array
sum = (xs: vec[i32]) i32 { fold(xs, 0, +) }

test("sum of array", () {
    assert(sum(xs) == 15)
})
```

Here, `xs` is an array of integers, and `sum` is a function that computes the sum of an array by folding over it.

### Pipelines

Mantis supports a pipeline syntax allowing you to pass the output of one function as the input for the next

```mantis
test("sum of first ten even squares", () {
    result = naturals()
        |> map((x) { x ^ 2 })
        |> filter((x) { x % 2 == 0 })
        |> take(10)
        |> sum()
    assert(result == 1140)
})
```

### For expressions

Mantis provides for expressions to efficiently iterate through an array and build up a new one.

```mantis
# Compute the dot product of two vectors
dot = [T: Num](a: vec[T], b: vec[T]) T {
    sum(for i { a[i] * b[i] })
}

# Perform matrix multiplication
matmul = [T: Num](a: mat[T], b: mat[T]) mat[T] {
    for i, j, k { sum(a[i, k] * b[k, j]) }
}
```

### Machine Learning

Mantis is designed with machine learning in mind. For expressions allow you to express how models work across a
single example rather than dealing with batches. Here is a simple linear model implemented in Mantis:

```mantis
Linear = struct {
    m: f64,
    b: f64
}

predict = ({m, b}: Linear, x: f64) f64 {
    m * x + b
}

sse = (model: Linear, x: vec[f64], y: vec[f64]) f64 {
    sum(for i {
        y_hat = predict(model, x[i])
        (y_hat - y[i]) ^ 2
    })
}

update = (model: Linear, gradient: Linear, learning_rate: f64) Linear {
    Linear{
        m: model.m - gradient.m * learning_rate,
        b: model.b - gradient.b * learning_rate,
    }
}

step = (model: Linear, learning_rate: f64, x: vec[f64], y: vec[f64]) Linear {
    gradient = grad(sse)(model, x, y)
    update(model, gradient, learning_rate)
}

test("gradient descent", () {
    model = {m: 1.0, b: 0.0}
    learning_rate = 0.01
    x = [1.0, 2.0, 3.0, 4.0]
    y = [2.0, 4.0, 6.0, 8.0]
    initial_loss = sse(model, x, y)
    model = step(model, learning_rate, x, y)
    updated_loss = sse(model, x, y)
    assert(updated_loss < initial_loss)
})
```

### HTML

Mantis is built to be a citizen of the web. We want to ensure you can build services which can render html
on the server side or client side.

```mantis
Customer = struct {
    name: str,
    age: u8,
}

customers: vec[Customer] = [
    {
        name: "Joe",
        age: 30
    },
    {
        name: "Sally",
        age: 27,
    }
]

get("/customers", () {
    <html>
        <head>
            <title>Customers</title>
        </head>
        <body>
            <ul>
                for i {
                    <li>
                        <h3>customers[i].name</h3>
                        <p>customers[i].age</p>
                    </li>
                }
            </ul>
        </body>
    </html>
})
```

## Community

Mantis is open-source and community-driven. We welcome contributions of any kind: code, documentation, design, etc.
Join our community and help us make Mantis the best language for machine learning and high-performance computing!

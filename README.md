# Intro

`AsyncMutexManager` is a concurrency control utility that helps manage and synchronize access to resources or sections of code across multiple tasks. It is particularly useful in scenarios where you need to limit the number of concurrent tasks running at any given time. Below is an example demonstrating how to use `AsyncMutexManager` to manage tasks with a concurrency limit.


<br/>

# Limiting Concurrent Tasks

Suppose you have a scenario where you want to run a set of asynchronous tasks but limit the number of tasks running simultaneously to a specified count. You can achieve this using AsyncMutexManager as follows:

```swift
let mutex = AsyncMutexManager(mutexCount: 2)

// Launching a task
Task {
    await mutex.willTask() // Request permission to run
    // ... Code that you want to run ...
    await mutex.didTask() // Notify completion
}

// Waiting for all tasks to finish
Task {
    await mutex.waitForFinish() // Wait until all tasks are done
    // ... Code that you want to run when all tasks are finished ...
}
```

<br/>

# Installation

### Swift Package Manager

``` swift
dependencies: [
    .package(url: "https://github.com/MaraMincho/SwiftAsyncMutex", .upToNextMajor(from: "1.0.0"))
]
```


<br/>


# Advanced Usage 

For detailed usage examples and to understand how `AsyncMutexManager` can be applied in various scenarios, please refer to the tests provided in the codebase. The tests demonstrate different use cases and edge cases for using `AsyncMutexManager `effectively.
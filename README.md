# SwiftAsyncMutex
SwiftAsyncMutex


# Intro

`AsyncMutexManager` is a concurrency control utility that helps manage and synchronize access to resources or sections of code across multiple tasks. It is particularly useful in scenarios where you need to limit the number of concurrent tasks running at any given time. Below is an example demonstrating how to use `AsyncMutexManager` to manage tasks with a concurrency limit.


# Limiting Concurrent Tasks

Suppose you have a scenario where you want to run a set of asynchronous tasks but limit the number of tasks running simultaneously to a specified count. You can achieve this using AsyncMutexManager as follows:

```swift
let mutex = AsyncMutexManager(mutexCount: 2) // Limit concurrent tasks to 2

Task {
    await mutex.wilTask()
    // Code that you will run
    await mutex.didTask()
}

```
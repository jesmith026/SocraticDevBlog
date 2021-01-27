---
layout: post
title: How to Mock HttpClient for your Unit Tests
category: testing
tags: testing mock httpclient
---

There are a number of methodologies that help you to mock HttpClient. Today I will focus on the scenarios where you have the ability to inject your own HttpClient instance.

An example of such a scenario is shown here:

```csharp
public class ApiProxy {
    private HttpClient client;

    public ApiProxy(HttpClient client) {
        this.client = client;
    }
}
```

# Setting up the Test API
For this demonstration I simply created a new API project and let the dotnet scaffolding do the rest.

```shell
dotnet new sln -n HttpClientMockExample;
dotnet new webapi -n Api;
dotnet sln HttpClientMockExample.sln add 
```

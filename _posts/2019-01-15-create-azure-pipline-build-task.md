---
layout: post
title: Creating an Azure Pipeline Build Task
category: devops
tags: "azure pipelines"
---

In this post we will walk through creating, testing, publishing, and installing a custom Azure Pipeline build task.

# What You Will Need
1. Text editor of your choice. I personally use Visual Studio Code which can be downloaded for free [here](https://code.visualstudio.com/download).
2. A Microsoft Account which can be set up for free [here](https://account.microsoft.com/account?lang=en-us).
3. An Azure DevOps organization where you have permission to install extensions. You can set one up for free [here](https://azure.microsoft.com/en-us/services/devops/?nav=min).
4. A publisher in the [Visual Studio Marketplace](https://marketplace.visualstudio.com/). You can set one up for free using your Microsoft account.
5. [Node.js](https://nodejs.org/en/download/).
6. TFS Cross Platform Command Line Interface (tfx-cli) can be installed by running `npm install -g tfx-cli`
7. PowerShell

If you would like to see the custom task created for this post you can find it on [GitHub](https://github.com/jesmith026/AzurePipeline.NugetPack).

# What are Azure Pipeline Build Tasks?
Build tasks as I refer to them here are a type of extension for Azure DevOps CI/CD pipeline. As described by Microsoft: "Extensions enhance Azure Devops Services (ADoS) and Team Foundation Server (TFS) by contributing enhancements like new web experiences, dashboard widgets, build tasks, and more". Extensions are developed using HTML, JavaScript, and CSS as well as any applicable scripting languages like PowerShell. They are packaged and published to the Visual Studio Marketplace and can then be installed into an ADoS organization.

# Overview
1. Create a custom task
2. Testing the task
3. Package your extension
4. Publish your extension

# Creating the Custom Task
## Scaffolding
The easiest way to get started would be to navigate to the desired directory and run `tfx build tasks create`. you will be prompted to provide a few data points and then the basic structure will be created for you.

- **Task Name:** The name of your task with no spaces
- **Friendly Task Name:** Descriptive name of your task - allows spaces
- **Task Description:** Detailed description of your task
- **Task Author:** Name of entity developing the task

Create vss-extension.json and README.md files in the root directory. Since we are creating a PowerShell task we can also delete the sample.js file.

At this point you should have a few key files:

<dl>
    <dt><strong>icon.png</strong></dt>
    <dd>This is the image which will appear for the task in Azure Pipelines.</dd>
    <dt><strong>sample.ps1</strong></dt>
    <dd>A sample script which will be run when targeting PowerShell</dd>
    <dt><strong>task.json</strong></dt>
    <dd>This file describes teh build or release task and is what Azure Pipelines uses to render configuration options to the user and to know which scripts to execute at build/release time.</dd>
    <dt><strong>vss-extension.json</strong></dt>
    <dd>Contains all of the information about your extension. It includes links to your files, including your task folders and images. We will be discussing this in more detail later.</dd>
</dl>

Next let's take a deeper look at the *task.json* file.

```json
{
    "id": "e3c59203-8498-4ec8-a3d1-a54cd547fb3b",
    "name": "SocraticProgrammer_DotnetNugetTask",
    "friendlyName": "Socratic Programmer - Dotnet Nuget Task",
    "description": "Wrapper for working with Nuget via the Dotnet CLI.",
    "helpMarkDown": "",
    "categories": [
        "Azure Pipelines"
    ],
    "author": "Socratic Programmer",
    "version": {
        "Major": 1,
        "Minor": 0,
        "Patch": 10
    },
    "instanceNameFormat": "Dotnet Nuget Pack $(Project)",
    "inputs": [
        {
            "name": "project",
            "type": "filePath",
            "label": "Project Path",
            "defaultValue": "",
            "required": true,
            "helpMarkDown": "Path to the desired project"
        },
        {
            "name": "output",
            "type": "filePath",
            "label": "Output Path",
            "defaultValue": "",
            "required": true,
            "helpMarkDown": "Path to the desired output directory"
        },
        {
            "name": "majorVersion",
            "type": "string",
            "label": "Major Version",
            "defaultValue": "",
            "required": true,
            "helpMarkDown": "Major version for the nuget package"
        },
        {
            "name": "minorVersion",
            "type": "string",
            "label": "Minor Version",
            "defaultValue": "",
            "required": true,
            "helpMarkDown": "Minor version for the nuget package"
        }        
    ],
    "execution": {
        "PowerShell3": {
            "target": "$(currentDirectory)\\task.ps1",
            "workingDirectory": "$(currentDirectory)"
        }        
    }
}
```
<dl>
    <dt><strong>id</strong></dt>
    <dd>A unique GUID for your task</dd>
    <dt><strong>name</strong></dt>
    <dd>The name of your task with no spaces</dd>
    <dt><strong>friendlyName</strong></dt>
    <dd>Descriptive name (spaces allowed)</dd>
    <dt><strong>description</strong></dt>
    <dd>Detailed description of your task</dd>
    <dt><strong>author</strong></dt>
    <dd>Name of the entity developing the task</dd>
    <dt><strong>instanceNameFormat</strong></dt>
    <dd>How the task will be displayed within the build or release step list. You can use variable values by using $(variablename)</dd>
    <dt><strong>inputs</strong></dt>
    <dd>Inputs to be used when your task runs</dd>
    <dt><strong>execution</strong></dt>
    <dd>Execution options for the task, including scripts</dd>
</dl>

Next we'll take a look at the *vss-extension.json* file. This manifest file contains all of the information about your extension. It includes links to your files, including your task folders and images. Below is an example from one of my custom tasks which you can view on [GitHub](https://github.com/jesmith026/AzurePipeline.NugetPack). For a more detailed description of the schema for this file you can check out the [extension manifest reference](https://docs.microsoft.com/en-us/azure/devops/extend/develop/manifest?view=azure-devops).

```json
{
    "manifestVersion": 1,
    "id": "Dotnet-Nuget-Build-Task",
    "name": "Dotnet Nuget",
    "version": "1.0.10",
    "publisher": "SocraticProgrammer",
    "targets": [
        {
            "id": "Microsoft.VisualStudio.Services"
        }
    ],    
    "description": "Task for working with Nuget via dotnet cli",
    "categories": [
        "Azure Pipelines"
    ],
    "icons": {
        "default": "images/SPLogo.png"
    },
    "files": [
        {
            "path": "buildAndReleaseTask"
        }
    ],
    "contributions": [
        {
            "id": "Socratic-Dotnet-Nuget-Build-Task",
            "type": "ms.vss-distributed-task.task",
            "targets": [
                "ms.vss-distributed-task.tasks"
            ],
            "properties": {
                "name": "buildAndReleaseTask"
            }
        }
    ]
}
```
<dl>
    <dt><strong>contributions.id</strong></dt>
    <dd>Must be unique within the extension. Does not need to match the name of the build or release task, but typically the build or release task name is included in the ID of the contribution.</dd>
    <dt><strong>contributions.type</strong></dt>
    <dd>Type of the contribution. Should be <strong>ms.vss-distributed-task.task</strong> for build tasks</dd>
    <dt><strong>contributions.targets</strong></dt>
    <dd>Contributions "targeted" by this contribution. Should be <strong>ms.vss-distributed-task.tasks</strong> for build tasks</dd>
    <dt><strong>contributions.properties.name</strong></dt>
    <dd>Name of the task. This must match the folder name of the corresponding self-contained build or release task pipeline</dd>
    <dt><strong>files.path</strong></dt>
    <dd>Path of the file or folder relative to the directory</dd>
</dl>

# Testing
There are a few ways we could go about testing this task. The first and simplest is to just execute the *sample.ps1* script using PowerShell. this would work fine as long as we weren't using any VSTS module functions, which the default scaffolding does. A much more thorough method is to execute the task through the VstsTaskSdk.

In order to do this, we'll first need to have the SDK saved locally. i personally opted to save it within my task folder under a *ps_modules* sub-folder.

Navigate to the directory you want to save the module files in and execute `Save-Module -Name VstsTaskSdk -Path .`

Next you'll want to copy the files out of the version folder and into the *VstsTaskSdk* folder.

Now you should have a folder structure similar to this:

![folder-structure](/images/posts/create-build-task/folder-structure.jpg)

Now we're ready to execute the task locally by importing the *VstsTaskSdk* module and executing the PowerShell script. Beginning in the root directory of your project execute the following commands after substituting the mustached values for the values in your project.

```bash
Import-Module "{{taskFolder}}\ps_modules\VstsTaskSdk\VstsTaskSdk.psd1;
& "{{taskFolder}}\task.ps1;
Remove-Module "VstsTaskSdk";
```

When the PowerShell script is executed any invocation of *Get-VstsInput* will cause the terminal to prompt for user input. Using the default task created in the scaffolding portion will ask for a *cwd* and a *msg* value from the user. Once entered it will proceed to change the working directory and print out the provided message.

Feel free to grab my Nuget task from [GitHub](https://github.com/jesmith026/AzurePipeline.NugetPack) to experiment further. The *devOps\test.ps1* script can be executed to perform these steps for you.

# Packaging Your Extension
Now that we can create working extensions we need to be able to package them for deployment into the Visual Studio Marketplace. To do this we'll use a *tfx* command.

```bash
tfx extension create --rev-version --output-path artifacts\ --manifest-globs vss-extension.json
```

This will package your extension into a *.vsix* file which can be uploaded to Visual Studio Marketplace. I saved this command as a script in my devOps folder along with the script to test the extension.

Notice the *--rev-version* option in the command. This will increment the version value inside the *vss-extension.json*. This newly incremented value will be used as the version for the *vsix* file. You'll probably want this value to come from your CI/CD pipeline eventually, but for now this will do.

# Publishing Your Extension
Now let's publish that extension to the marketplace. If you haven't already, you can set up a publisher account using your Microsoft account. After doing so you can select the **New Extension** drop down and select the appropriate option (in our case that would be Azure DevOps). Upload the *vsix* file and once the verificaiton process has completed the extension is officially published.

![Marketplace](/images/posts/create-build-task/marketplace.jpg)

Extensions default to private but can either be set public or shared directly with an Azure DevOps Organization.

Once you've made the extension available to your organization (either through publishing publicly or sharing privately) then the task will be available to use in your Azure Pipelines build definition.

![Pipeline Task](/images/posts/create-build-task/pipeline-task.jpg)
namespace FuncApp {

    using System;
    using Azure.Identity;
    using Microsoft.Azure.Functions.Extensions.DependencyInjection;
    using Microsoft.Extensions.Configuration;
    using Microsoft.Extensions.Configuration.AzureAppConfiguration;

    public class Startup : FunctionsStartup {

        public override void ConfigureAppConfiguration(IFunctionsConfigurationBuilder builder) {
            builder.ConfigurationBuilder
                   .AddAzureAppConfiguration(options => {
                        options.Connect(new Uri(Environment.GetEnvironmentVariable("AZURE_APPCONFIG_URL")), new DefaultAzureCredential())
                               .Select(KeyFilter.Any, LabelFilter.Null);
                    })
                   .AddEnvironmentVariables();
        }

        public override void Configure(IFunctionsHostBuilder builder) {
            return;
        }
        
    }

}
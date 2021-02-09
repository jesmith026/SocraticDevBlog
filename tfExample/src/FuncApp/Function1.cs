using System;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;

namespace FuncApp
{
    public static class Function1
    {
        [FunctionName("subscription")]
        public static void Run([ServiceBusTrigger("%ServiceBus:Topic%", "%ServiceBus:Subscription%")]string mySbMsg, ILogger logger)
        {
            logger.LogInformation($"Trigger executed with message {mySbMsg}");
        }
    }
}

﻿using System;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using Domain0.Service;

namespace Domain0.Nancy.Service
{
    public class SmsGatewayClient : ISmsClient
    {
        public SmsGatewayClient(SmsGatewaySettings settingsInstance)
        {
            httpClient = new HttpClient { BaseAddress = new Uri(settingsInstance.Host) };
            httpClient.DefaultRequestHeaders.Accept
                .Add(new MediaTypeWithQualityHeaderValue("application/json"));
                
            httpClient.DefaultRequestHeaders.Authorization = 
                new AuthenticationHeaderValue("Bearer", settingsInstance.Token);
        }


        public async Task Send(decimal phone, string message, string environment)
        {
            var urlBuilder = new System.Text.StringBuilder();
            urlBuilder.Append($"/sms/{phone}?");
            urlBuilder.Append("message=").Append(Uri.EscapeDataString(message)).Append("&");
            urlBuilder.Append("environmenttoken=").Append(Uri.EscapeDataString(environment)).Append("&");
            urlBuilder.Length--;

            var request = new HttpRequestMessage(HttpMethod.Put, urlBuilder.ToString());
            var sendStatus = await httpClient.SendAsync(request);
            sendStatus.EnsureSuccessStatusCode();
        }

        private readonly HttpClient httpClient;
    }
}

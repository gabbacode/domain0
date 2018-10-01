﻿using System.Threading.Tasks;
using Domain0.Exceptions;
using Domain0.Model;
using Domain0.Service;
using Domain0.Service.Tokens;
using Nancy;
using Nancy.Security;
using Nancy.Swagger.Annotations.Attributes;
using NLog;
using Swagger.ObjectModel;

namespace Domain0.Nancy
{
    public sealed class UsersModule : NancyModule
    {
        public const string GetMyProfileUrl = "/api/profile";
        public const string GetUserByPhoneUrl = "/api/users/sms/{phone}";
        public const string GetUserByIdUrl = "/api/users/{id}";


        public UsersModule(
            IAccountService accountServiceInstance,
            ILogger loggerInstance)
        {
            Get(GetMyProfileUrl, ctx => GetMyProfile(), name: nameof(GetMyProfile));
            Get(GetUserByPhoneUrl, ctx => GetUserByPhone(), name: nameof(GetUserByPhone));
            Get(GetUserByIdUrl, ctx => GetUserById(), name: nameof(GetUserById));


            accountService = accountServiceInstance;
            logger = loggerInstance;
        }

        [Route(nameof(GetMyProfile))]
        [Route(HttpMethod.Get, GetMyProfileUrl)]
        [Route(Produces = new[] { "application/json", "application/x-protobuf" })]
        [Route(Tags = new[] { "UserProfile" }, Summary = "Method for receive own profile")]
        [SwaggerResponse(HttpStatusCode.OK, Message = "Success", Model = typeof(UserProfile))]
        public async Task<object> GetMyProfile()
        {
            this.RequiresAuthentication();

            var profile = await accountService.GetMyProfile();
            return profile;
        }

        [Route(nameof(GetUserByPhone))]
        [Route(HttpMethod.Get, GetUserByPhoneUrl)]
        [Route(Produces = new[] { "application/json", "application/x-protobuf" })]
        [Route(Tags = new[] { "Users" }, Summary = "Method for receive profile by phone")]
        [RouteParam(ParamIn = ParameterIn.Path, Name = "phone", ParamType = typeof(long), Required = true, Description = "User phone")]
        [SwaggerResponse(HttpStatusCode.OK, Message = "Success", Model = typeof(UserProfile))]
        public async Task<object> GetUserByPhone()
        {
            this.RequiresAuthentication();
            this.RequiresClaims(c =>
                c.Type == TokenClaims.CLAIM_PERMISSIONS
                && c.Value.Contains(TokenClaims.CLAIM_PERMISSIONS_VIEW_USERS));

            if (!decimal.TryParse(Context.Parameters.phone.ToString(), out decimal phone))
            {
                ModelValidationResult.Errors.Add(nameof(phone), "bad format");
                throw new BadModelException(ModelValidationResult);
            }

            var profile = await accountService.GetProfileByPhone(phone);
            return profile;
        }

        [Route(nameof(GetUserById))]
        [Route(HttpMethod.Get, GetUserByIdUrl)]
        [Route(Produces = new[] { "application/json", "application/x-protobuf" })]
        [Route(Tags = new[] { "Users" }, Summary = "Method for receive profile by user id")]
        [RouteParam(ParamIn = ParameterIn.Path, Name = "id", ParamType = typeof(int), Required = true, Description = "User id")]
        [SwaggerResponse(HttpStatusCode.OK, Message = "Success", Model = typeof(UserProfile))]
        public async Task<object> GetUserById()
        {
            this.RequiresAuthentication();
            this.RequiresClaims(c =>
                c.Type == TokenClaims.CLAIM_PERMISSIONS
                && c.Value.Contains(TokenClaims.CLAIM_PERMISSIONS_VIEW_USERS));

            var id = Context.Parameters.id;
            var profile = await accountService.GetProfileByUserId(id);
            return profile;
        }

        private readonly IAccountService accountService;

        private readonly ILogger logger;
    }
}

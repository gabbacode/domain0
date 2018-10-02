﻿if not exists (select top 1 1 from sys.schemas where name='dom')
	exec sp_executesql N'create schema dom' 
go
if object_id('dom.PermissionUser') is not null
	drop table dom.PermissionUser
go
if object_id('dom.RoleUser') is not null
	drop table dom.RoleUser
go
if object_id('dom.PermissionRole') is not null
	drop table dom.PermissionRole
go
if object_id('dom.Role') is not null
	drop table dom.Role
go
if object_id('dom.Permission') is not null
	drop table dom.Permission
go
if object_id('dom.Application') is not null
	drop table dom.Application
go
if object_id('dom.Account') is not null
	drop table dom.Account
go
if object_id('dom.SmsRequest') is not null
	drop table dom.SmsRequest
go
if object_id('dom.EmailRequest') is not null
	drop table dom.EmailRequest
go
if object_id('dom.Message') is not null
	drop table dom.Message
go
if object_id('dom.TokenRegistration') is not null
	drop table dom.TokenRegistration
go


create table dom.Role (
	Id int not null identity(1,1) constraint PK_dom_Role primary key,
	Name nvarchar(64) not null,
	Description nvarchar(max) null,
	IsDefault bit not null default(0),

	constraint UQ_dom_Role unique(Name)
)
go
create index IX_Role_Name ON dom.Role ([Name])


create table dom.Application (
	Id int not null identity(1,1) constraint PK_dom_Application primary key,
	Name nvarchar(64) not null,
	Description nvarchar(max) null
)
go


create table dom.Permission (
	Id int not null identity(1,1) constraint PK_dom_Permission primary key,
	ApplicationId int not null constraint FK_dom_Permission_ApplicationId foreign key references dom.Application(Id),
	Name nvarchar(64) not null,
	Description nvarchar(max) null

	constraint UQ_dom_Permission unique(Name)
)
go
create index IX_Permission_Name ON dom.Permission ([Name])
go


create table dom.PermissionRole (
	PermissionId int not null constraint FK_dom_PermissionRole_PermissionId foreign key references dom.Permission(Id),
	RoleId int not null constraint FK_dom_PermissionRole_RoleId foreign key references dom.Role(Id)

	constraint PK_dom_PermissionRole primary key(PermissionId, RoleId)
)
go


create table dom.Account (
	[Id] int identity(1,1) not null constraint PK_Account_Id primary key,
	[Email] nvarchar(128) null,
	[Phone] decimal null,
	[Login] nvarchar(80) null,
	[Password] nvarchar(80) null,
	[Name] nvarchar(256) not null,
	[Description] nvarchar(max) null
)
go
create index IX_Account_Phone ON dom.Account ([Phone])
create index IX_Account_Email ON dom.Account ([Email])
create index IX_Account_Login ON dom.Account ([Login])
go


create table dom.RoleUser (
	RoleId int not null constraint FK_dom_RoleUser_RoleId foreign key references dom.Role(Id),
	UserId int not null constraint FK_dom_RoleUser_UserId foreign key references dom.Account(Id)

	constraint PK_dom_RoleUser primary key(RoleId, UserId)
)
go
create index IX_RoleUser_UserId ON dom.RoleUser ([UserId])
go


create table dom.PermissionUser (
	PermissionId int not null,
	UserId int not null,
	Since datetime2 null,
	Until datetime2 null

	constraint PK_dom_PermissionUser primary key(PermissionId, UserId)
)
go


create table dom.Message (
	Id int identity(1,1) not null constraint PK_Message_Id primary key,
	Description nvarchar(max) null,
	Type nvarchar(10) null,
	Locale nvarchar(3) null,
	Name nvarchar(256) not null,
	Template nvarchar(max) not null
)
go

insert into dom.Message 
([Type], [Locale], [Name], [Template])
values
('sms',		'en',		'WelcomeTemplate',		'Hello {0}!'),
('sms',		'en',		'RegisterTemplate',		'Your password is: {0} will valid for {1} min'),
('sms',		'en',		'RequestResetTemplate',	'Your NEW password is: {0} will valid for {1} min'),
('sms',		'ru',		'WelcomeTemplate',		'Добро пожаловать {0}!'),
('sms',		'ru',		'RegisterTemplate',		'Ваш пароль: {0} действителен {1} мин'),
('sms',		'ru',		'RequestResetTemplate',	'Ваш НОВЫЙ пароль: {0} действителен {1} мин'),

('email',	'en',		'WelcomeTemplate',		'Hello {0}!'),
('email',	'en',		'RegisterTemplate',		'Your password is: {0} will valid for {1} min'),
('email',	'en',		'RegisterSubjectTemplate',	'Dear {0}! Welcome to {1}'),
('email',	'en',		'RequestResetTemplate',	'Your NEW password is: {0} will valid for {1} min'),
('email',	'en',		'RequestResetSubjectTemplate',	'{0}.Change password for {1}'),
('email',	'ru',		'WelcomeTemplate',		'Добро пожаловать {0}!'),
('email',	'ru',		'RegisterTemplate',		'Ваш пароль: {0} действителен {1} мин'),
('email',	'ru',		'RegisterSubjectTemplate',	'{0}! Добро пожаловать в {1}'),
('email',	'ru',		'RequestResetTemplate',	'Ваш НОВЫЙ пароль: {0} действителен {1} мин'),
('email',	'ru',		'RequestResetSubjectTemplate',	'{0}. Изменение пароля для {1}')
go
create index IX_Message_Name_Type_Locale ON dom.Message ([Name] asc, [Type] asc, [Locale] asc)
go


create table dom.SmsRequest (
	[Id] int identity(1,1) not null constraint PK_SmsRequest_Id primary key,
	[Phone] decimal not null,
	[Password] nvarchar(80) not null,
	[ExpiredAt] datetime2 not null,
	[UserId] int null
)
go
create index IX_SmsRequest_Phone_ExpiredAt ON dom.SmsRequest ([Phone] ASC, [ExpiredAt] DESC)
go
create index IX_SmsRequest_UserId_ExpiredAt ON dom.SmsRequest ([UserId] ASC, [ExpiredAt] DESC)
go


create table dom.EmailRequest (
	[Id] int identity(1,1) not null constraint PK_EmailRequest_Id primary key,
	[Email] nvarchar(128) not null,
	[Password] nvarchar(80) not null,
	[ExpiredAt] datetime2 not null,
	[UserId] int null
)
go
create index IX_EmailRequest_Email_ExpiredAt ON dom.EmailRequest ([Email] ASC, [ExpiredAt] DESC)
go
create index IX_EmailRequest_UserId_ExpiredAt ON dom.EmailRequest ([UserId] ASC, [ExpiredAt] DESC)
go


create table dom.TokenRegistration (
	[Id] int identity(1,1) not null constraint PK_TokenRegistration_Id primary key,
	[UserId] int not null,
	[AccessToken] nvarchar(max) not null,
	[IssuedAt] datetime2 not null,
	[ExpiredAt] datetime2 null
)
go

/*
insert into [dom].[Application]
([Name], [Description])
values
('Domain0', 'Domain0 auth app')

declare @DomainAppId int = SCOPE_IDENTITY();

insert into [dom].[Permission]
([ApplicationId], [Name], [Description])
values
(@DomainAppId, 'Admin', 'Admin permission')
*/

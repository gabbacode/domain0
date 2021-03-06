﻿if not exists (select top 1 1 from sys.schemas where name='dom')
	exec sp_executesql N'create schema dom' 
go

if not exists (select top 1 1 from sys.schemas where name='hst_dom')
	exec sp_executesql N'create schema hst_dom' 
go

if not exists (select top 1 1 from sys.schemas where name='log')
	exec sp_executesql N'create schema log' 
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
if object_id('dom.AccountEnvironment') is not null
	drop table dom.AccountEnvironment
go
if object_id('dom.Environment') is not null
	drop table dom.Environment
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
if object_id('dom.ImpersonationSession') is not null
	drop table dom.ImpersonationSession
go
if object_id('log.Access') is not null
	drop table log.Access
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

create table dom.Environment (
	Id int not null identity(1,1) constraint PK_dom_Environment primary key,
	Name nvarchar(64) not null,
	Description nvarchar(128) null,
	Token nvarchar(128) not null,
	IsDefault bit not null default(0),
)
go
create unique index IX_Environment_Token ON dom.Environment ([Token])


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
	[Name] nvarchar(256) null,
	[Description] nvarchar(max) null,
	[FirstDate] datetime null,
	[LastDate] datetime null,
	[IsLocked] bit not null default(0)
)
go
create index IX_Account_Phone ON dom.Account ([Phone])
create index IX_Account_Email ON dom.Account ([Email])
create index IX_Account_Login ON dom.Account ([Login])
go

create table dom.AccountEnvironment (
	EnvironmentId int not null constraint FK_dom_AccountEnvironment_Id foreign key references dom.Environment(Id),
	UserId int not null constraint FK_dom_AccountEnvironment_UserId foreign key references dom.Account(Id) on delete cascade

	constraint PK_dom_AccountEnvironment primary key(EnvironmentId, UserId)
)
go

create table dom.RoleUser (
	RoleId int not null constraint FK_dom_RoleUser_RoleId foreign key references dom.Role(Id),
	UserId int not null constraint FK_dom_RoleUser_UserId foreign key references dom.Account(Id) on delete cascade

	constraint PK_dom_RoleUser primary key(RoleId, UserId)
)
go
create index IX_RoleUser_UserId ON dom.RoleUser ([UserId])
go


create table dom.PermissionUser (
	PermissionId int not null,
	UserId int not null constraint FK_dom_PermissionUser_UserId foreign key references dom.Account(Id) on delete cascade,
	Since datetime2 null,
	Until datetime2 null

	constraint PK_dom_PermissionUser primary key(PermissionId, UserId)
)
go


create table dom.Message (
	Id int identity(1,1) not null constraint PK_Message_Id primary key,
	Description nvarchar(max) null,
	Type nvarchar(10) null,
	Locale nvarchar(20) null,
	Name nvarchar(256) not null,
	Template nvarchar(max) not null,
	EnvironmentId int not null
)
go
create index IX_Message_Name_Type_Locale ON dom.Message ([Name] asc, [Type] asc, [Locale] asc)
go


create table dom.SmsRequest (
	[Id] int identity(1,1) not null constraint PK_SmsRequest_Id primary key,
	[Phone] decimal not null,
	[Password] nvarchar(80) not null,
	[ExpiredAt] datetime2 not null,
	[UserId] int null,
	[EnvironmentId] int null
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
	[UserId] int null,
	[EnvironmentId] int null
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

create table log.Access(
	[Id] bigint identity(1,1) not null constraint PK_log_Access_Id primary key,
	[Action] nvarchar(max) not null,
	[Method] nvarchar(max) not null,
	[ClientIp] nvarchar(max) not null,
	[ProcessedAt] datetime not null,
	[StatusCode] int null,
	[UserAgent] nvarchar(max) not null,
	[UserId] nvarchar(max) null,
	[Referer] nvarchar(max) null,
	[ProcessingTime] int null,
	[AcceptLanguage] nvarchar(max) null
)
go

create table dom.ImpersonationSession (
	[Id] int identity(1,1) not null constraint PK_Impersonation_Id primary key,
	[Opened] datetime not null,
	[Closed] datetime null,
	[UserId] int not null,
	[PersonUserId] int not null
)
go
create index IX_ImpersonationSession_UserId_OpenedDate 
	on dom.ImpersonationSession ([UserId] ASC, [Opened] DESC)
	include([Closed])
go


if object_id('[hst_dom].[Application]') is not null
	DROP TABLE [hst_dom].[Application]
GO

if object_id('[hst_dom].[TokenRegistration]') is not null
	DROP TABLE [hst_dom].[TokenRegistration]
GO

if object_id('[hst_dom].[SmsRequest]') is not null
	DROP TABLE [hst_dom].[SmsRequest]
GO

if object_id('[hst_dom].[RoleUser]') is not null
	DROP TABLE [hst_dom].[RoleUser]
GO

if object_id('[hst_dom].[Role]') is not null
	DROP TABLE [hst_dom].[Role]
GO

if object_id('[hst_dom].[PermissionUser]') is not null
	DROP TABLE [hst_dom].[PermissionUser]
GO

if object_id('[hst_dom].[PermissionRole]') is not null
	DROP TABLE [hst_dom].[PermissionRole]
GO

if object_id('[hst_dom].[Permission]') is not null
	DROP TABLE [hst_dom].[Permission]
GO

if object_id('[hst_dom].[Message]') is not null
	DROP TABLE [hst_dom].[Message]
GO

if object_id('[hst_dom].[EmailRequest]') is not null
	DROP TABLE [hst_dom].[EmailRequest]
GO

if object_id('[hst_dom].[Application]') is not null
	DROP TABLE [hst_dom].[Application]
GO

if object_id('[hst_dom].[Environment]') is not null
	DROP TABLE [hst_dom].[Environment]
GO

if object_id('[hst_dom].[Account]') is not null
	DROP TABLE [hst_dom].[Account]
GO

CREATE TABLE [hst_dom].[Account](
	[H_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[H_ConnectionID] [uniqueidentifier] NOT NULL,
	[H_TransactionID] [bigint] NOT NULL,
	[H_SessionID] [int] NOT NULL,
	[H_Login] [nvarchar](128) NOT NULL,
	[H_Time] [datetime2](7) NOT NULL,
	[H_OperationType] [int] NOT NULL,
	[H_IsNew] [bit] NOT NULL,
	[Id] [int] NULL,
	[Email] [nvarchar](128) NULL,
	[Phone] [decimal](18, 0) NULL,
	[Login] [nvarchar](80) NULL,
	[Password] [nvarchar](80) NULL,
	[Name] [nvarchar](256) NULL,
	[Description] [nvarchar](max) NULL,
	[FirstDate] datetime null,
	[LastDate] datetime null,
	[IsLocked] bit null

 CONSTRAINT [PK_Account_History] PRIMARY KEY CLUSTERED 
(
	[H_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


CREATE TABLE [hst_dom].[Application](
	[H_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[H_ConnectionID] [uniqueidentifier] NOT NULL,
	[H_TransactionID] [bigint] NOT NULL,
	[H_SessionID] [int] NOT NULL,
	[H_Login] [nvarchar](128) NOT NULL,
	[H_Time] [datetime2](7) NOT NULL,
	[H_OperationType] [int] NOT NULL,
	[H_IsNew] [bit] NOT NULL,
	[Id] [int] NULL,
	[Name] [nvarchar](64) NULL,
	[Description] [nvarchar](max) NULL,
 CONSTRAINT [PK_Application_History] PRIMARY KEY CLUSTERED 
(
	[H_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


CREATE TABLE [hst_dom].[Environment](
	[H_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[H_ConnectionID] [uniqueidentifier] NOT NULL,
	[H_TransactionID] [bigint] NOT NULL,
	[H_SessionID] [int] NOT NULL,
	[H_Login] [nvarchar](128) NOT NULL,
	[H_Time] [datetime2](7) NOT NULL,
	[H_OperationType] [int] NOT NULL,
	[H_IsNew] [bit] NOT NULL,
	[Id] [int] NULL,
	[Name] [nvarchar](64) NULL,
	[Description] [nvarchar](128) NULL,
	[Token] [nvarchar](128) NULL,
	[IsDefault] [bit] NULL,
 CONSTRAINT [PK_Environment_History] PRIMARY KEY CLUSTERED 
(
	[H_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [hst_dom].[EmailRequest](
	[H_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[H_ConnectionID] [uniqueidentifier] NOT NULL,
	[H_TransactionID] [bigint] NOT NULL,
	[H_SessionID] [int] NOT NULL,
	[H_Login] [nvarchar](128) NOT NULL,
	[H_Time] [datetime2](7) NOT NULL,
	[H_OperationType] [int] NOT NULL,
	[H_IsNew] [bit] NOT NULL,
	[Id] [int] NULL,
	[Email] [nvarchar](128) NULL,
	[Password] [nvarchar](80) NULL,
	[ExpiredAt] [datetime2](7) NULL,
	[UserId] [int] NULL,
	[EnvironmentId] int NULL
 CONSTRAINT [PK_EmailRequest_History] PRIMARY KEY CLUSTERED 
(
	[H_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


CREATE TABLE [hst_dom].[Message](
	[H_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[H_ConnectionID] [uniqueidentifier] NOT NULL,
	[H_TransactionID] [bigint] NOT NULL,
	[H_SessionID] [int] NOT NULL,
	[H_Login] [nvarchar](128) NOT NULL,
	[H_Time] [datetime2](7) NOT NULL,
	[H_OperationType] [int] NOT NULL,
	[H_IsNew] [bit] NOT NULL,
	[Id] [int] NULL,
	[Description] [nvarchar](max) NULL,
	[Type] [nvarchar](10) NULL,
	[Locale] [nvarchar](20) NULL,
	[Name] [nvarchar](256) NULL,
	[Template] [nvarchar](max) NULL,
	[EnvironmentId] int null,
 CONSTRAINT [PK_Message_History] PRIMARY KEY CLUSTERED 
(
	[H_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


CREATE TABLE [hst_dom].[Permission](
	[H_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[H_ConnectionID] [uniqueidentifier] NOT NULL,
	[H_TransactionID] [bigint] NOT NULL,
	[H_SessionID] [int] NOT NULL,
	[H_Login] [nvarchar](128) NOT NULL,
	[H_Time] [datetime2](7) NOT NULL,
	[H_OperationType] [int] NOT NULL,
	[H_IsNew] [bit] NOT NULL,
	[Id] [int] NULL,
	[ApplicationId] [int] NULL,
	[Name] [nvarchar](64) NULL,
	[Description] [nvarchar](max) NULL,
 CONSTRAINT [PK_Permission_History] PRIMARY KEY CLUSTERED 
(
	[H_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [hst_dom].[PermissionRole](
	[H_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[H_ConnectionID] [uniqueidentifier] NOT NULL,
	[H_TransactionID] [bigint] NOT NULL,
	[H_SessionID] [int] NOT NULL,
	[H_Login] [nvarchar](128) NOT NULL,
	[H_Time] [datetime2](7) NOT NULL,
	[H_OperationType] [int] NOT NULL,
	[H_IsNew] [bit] NOT NULL,
	[PermissionId] [int] NULL,
	[RoleId] [int] NULL,
 CONSTRAINT [PK_PermissionRole_History] PRIMARY KEY CLUSTERED 
(
	[H_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


CREATE TABLE [hst_dom].[PermissionUser](
	[H_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[H_ConnectionID] [uniqueidentifier] NOT NULL,
	[H_TransactionID] [bigint] NOT NULL,
	[H_SessionID] [int] NOT NULL,
	[H_Login] [nvarchar](128) NOT NULL,
	[H_Time] [datetime2](7) NOT NULL,
	[H_OperationType] [int] NOT NULL,
	[H_IsNew] [bit] NOT NULL,
	[PermissionId] [int] NULL,
	[UserId] [int] NULL,
	[Since] [datetime2](7) NULL,
	[Until] [datetime2](7) NULL,
 CONSTRAINT [PK_PermissionUser_History] PRIMARY KEY CLUSTERED 
(
	[H_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


CREATE TABLE [hst_dom].[Role](
	[H_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[H_ConnectionID] [uniqueidentifier] NOT NULL,
	[H_TransactionID] [bigint] NOT NULL,
	[H_SessionID] [int] NOT NULL,
	[H_Login] [nvarchar](128) NOT NULL,
	[H_Time] [datetime2](7) NOT NULL,
	[H_OperationType] [int] NOT NULL,
	[H_IsNew] [bit] NOT NULL,
	[Id] [int] NULL,
	[Name] [nvarchar](64) NULL,
	[Description] [nvarchar](max) NULL,
	[IsDefault] [bit] NULL,
 CONSTRAINT [PK_Role_History] PRIMARY KEY CLUSTERED 
(
	[H_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [hst_dom].[RoleUser](
	[H_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[H_ConnectionID] [uniqueidentifier] NOT NULL,
	[H_TransactionID] [bigint] NOT NULL,
	[H_SessionID] [int] NOT NULL,
	[H_Login] [nvarchar](128) NOT NULL,
	[H_Time] [datetime2](7) NOT NULL,
	[H_OperationType] [int] NOT NULL,
	[H_IsNew] [bit] NOT NULL,
	[RoleId] [int] NULL,
	[UserId] [int] NULL,
 CONSTRAINT [PK_RoleUser_History] PRIMARY KEY CLUSTERED 
(
	[H_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [hst_dom].[SmsRequest](
	[H_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[H_ConnectionID] [uniqueidentifier] NOT NULL,
	[H_TransactionID] [bigint] NOT NULL,
	[H_SessionID] [int] NOT NULL,
	[H_Login] [nvarchar](128) NOT NULL,
	[H_Time] [datetime2](7) NOT NULL,
	[H_OperationType] [int] NOT NULL,
	[H_IsNew] [bit] NOT NULL,
	[Id] [int] NULL,
	[Phone] [decimal](18, 0) NULL,
	[Password] [nvarchar](80) NULL,
	[ExpiredAt] [datetime2](7) NULL,
	[UserId] [int] NULL,
	[EnvironmentId] int NULL
 CONSTRAINT [PK_SmsRequest_History] PRIMARY KEY CLUSTERED 
(
	[H_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [hst_dom].[TokenRegistration](
	[H_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[H_ConnectionID] [uniqueidentifier] NOT NULL,
	[H_TransactionID] [bigint] NOT NULL,
	[H_SessionID] [int] NOT NULL,
	[H_Login] [nvarchar](128) NOT NULL,
	[H_Time] [datetime2](7) NOT NULL,
	[H_OperationType] [int] NOT NULL,
	[H_IsNew] [bit] NOT NULL,
	[Id] [int] NULL,
	[UserId] [int] NULL,
	[AccessToken] [nvarchar](max) NULL,
	[IssuedAt] [datetime2](7) NULL,
	[ExpiredAt] [datetime2](7) NULL,
 CONSTRAINT [PK_TokenRegistration_History] PRIMARY KEY CLUSTERED 
(
	[H_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TRIGGER [dom].[AccountHistory]
   ON  [dom].[Account]
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN

	SET NOCOUNT ON;

declare @delExists bit;
declare @insExists bit;

if exists(select top 1 1 from deleted) set @delExists = 1
if exists(select top 1 1 from inserted) set @insExists = 1

declare @opType int;

if (@delExists = 1)
	if (@insExists = 1)
		set @opType = 2
	else 
		set @opType = 3
else
	if (@insExists = 1)
		set @opType = 1
	else 
		set @opType = 0
		
if (@opType = 0)
	return;	

declare @time datetime2(7) = SYSUTCDATETIME()
declare @connection_id uniqueidentifier = (select connection_id from sys.dm_exec_connections where session_id = @@SPID and parent_connection_id is null)
--declare @transaction_id bigint = (select transaction_id from sys.dm_tran_current_transaction)
declare @transaction_id bigint = (select transaction_id from sys.dm_tran_session_transactions where session_id = @@SPID)
declare @login nvarchar(128) = ORIGINAL_LOGIN()


insert into [hst_dom].[Account] ([H_ConnectionID], [H_TransactionID], [H_SessionID], [H_Login], [H_Time], [H_OperationType], [H_IsNew]
-- data columns
	,[Id]
	,[Email]
	,[Phone]
	,[Login]
	,[Password]
	,[Name]
	,[Description]
	,[FirstDate]
	,[LastDate]
	,[IsLocked]
)
select @connection_id, @transaction_id, @@SPID, @login, @time, @opType, h.H_IsNew
-- data columns
	,h.[Id]
	,h.[Email]
	,h.[Phone]
	,h.[Login]
	,h.[Password]
	,h.[Name]
	,h.[Description]
	,h.[FirstDate]
	,h.[LastDate]
	,h.[IsLocked]
from 
(
	select 0 as H_IsNew, t.* 
	from deleted t
	union all
	select 1 as H_IsNew, t.* 
	from inserted t
) h
order by h.Id, h.H_IsNew


END;

GO
ALTER TABLE [dom].[Account] ENABLE TRIGGER [AccountHistory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dom].[ApplicationHistory]
   ON  [dom].[Application]
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN

	SET NOCOUNT ON;

declare @delExists bit;
declare @insExists bit;

if exists(select top 1 1 from deleted) set @delExists = 1
if exists(select top 1 1 from inserted) set @insExists = 1

declare @opType int;

if (@delExists = 1)
	if (@insExists = 1)
		set @opType = 2
	else 
		set @opType = 3
else
	if (@insExists = 1)
		set @opType = 1
	else 
		set @opType = 0
		
if (@opType = 0)
	return;	

declare @time datetime2(7) = SYSUTCDATETIME()
declare @connection_id uniqueidentifier = (select connection_id from sys.dm_exec_connections where session_id = @@SPID and parent_connection_id is null)
--declare @transaction_id bigint = (select transaction_id from sys.dm_tran_current_transaction)
declare @transaction_id bigint = (select transaction_id from sys.dm_tran_session_transactions where session_id = @@SPID)
declare @login nvarchar(128) = ORIGINAL_LOGIN()


insert into [hst_dom].[Application] ([H_ConnectionID], [H_TransactionID], [H_SessionID], [H_Login], [H_Time], [H_OperationType], [H_IsNew]
-- data columns
	,[Id]
	,[Name]
	,[Description])
select @connection_id, @transaction_id, @@SPID, @login, @time, @opType, h.H_IsNew
-- data columns
	,h.[Id]
	,h.[Name]
	,h.[Description]
from 
(
	select 0 as H_IsNew, t.* 
	from deleted t
	union all
	select 1 as H_IsNew, t.* 
	from inserted t
) h
order by h.Id, h.H_IsNew


END;

GO
ALTER TABLE [dom].[Application] ENABLE TRIGGER [ApplicationHistory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dom].[EnvironmentHistory]
   ON  [dom].[Environment]
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN

	SET NOCOUNT ON;

declare @delExists bit;
declare @insExists bit;

if exists(select top 1 1 from deleted) set @delExists = 1
if exists(select top 1 1 from inserted) set @insExists = 1

declare @opType int;

if (@delExists = 1)
	if (@insExists = 1)
		set @opType = 2
	else 
		set @opType = 3
else
	if (@insExists = 1)
		set @opType = 1
	else 
		set @opType = 0
		
if (@opType = 0)
	return;	

declare @time datetime2(7) = SYSUTCDATETIME()
declare @connection_id uniqueidentifier = (select connection_id from sys.dm_exec_connections where session_id = @@SPID and parent_connection_id is null)
--declare @transaction_id bigint = (select transaction_id from sys.dm_tran_current_transaction)
declare @transaction_id bigint = (select transaction_id from sys.dm_tran_session_transactions where session_id = @@SPID)
declare @login nvarchar(128) = ORIGINAL_LOGIN()


insert into [hst_dom].[Environment] ([H_ConnectionID], [H_TransactionID], [H_SessionID], [H_Login], [H_Time], [H_OperationType], [H_IsNew]
-- data columns
	,[Id]
	,[Name]
	,[Description]
	,[Token]
	,[IsDefault])
select @connection_id, @transaction_id, @@SPID, @login, @time, @opType, h.H_IsNew
-- data columns
	,h.[Id]
	,h.[Name]
	,h.[Description]
	,h.[Token]
	,h.[IsDefault]
from 
(
	select 0 as H_IsNew, t.* 
	from deleted t
	union all
	select 1 as H_IsNew, t.* 
	from inserted t
) h
order by h.Id, h.H_IsNew


END;

GO
ALTER TABLE [dom].[Environment] ENABLE TRIGGER [EnvironmentHistory]
GO

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dom].[EmailRequestHistory]
   ON  [dom].[EmailRequest]
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN

	SET NOCOUNT ON;

declare @delExists bit;
declare @insExists bit;

if exists(select top 1 1 from deleted) set @delExists = 1
if exists(select top 1 1 from inserted) set @insExists = 1

declare @opType int;

if (@delExists = 1)
	if (@insExists = 1)
		set @opType = 2
	else 
		set @opType = 3
else
	if (@insExists = 1)
		set @opType = 1
	else 
		set @opType = 0
		
if (@opType = 0)
	return;	

declare @time datetime2(7) = SYSUTCDATETIME()
declare @connection_id uniqueidentifier = (select connection_id from sys.dm_exec_connections where session_id = @@SPID and parent_connection_id is null)
--declare @transaction_id bigint = (select transaction_id from sys.dm_tran_current_transaction)
declare @transaction_id bigint = (select transaction_id from sys.dm_tran_session_transactions where session_id = @@SPID)
declare @login nvarchar(128) = ORIGINAL_LOGIN()


insert into [hst_dom].[EmailRequest] ([H_ConnectionID], [H_TransactionID], [H_SessionID], [H_Login], [H_Time], [H_OperationType], [H_IsNew]
-- data columns
	,[Id]
	,[Email]
	,[Password]
	,[ExpiredAt]
	,[UserId]
	,[EnvironmentId])
select @connection_id, @transaction_id, @@SPID, @login, @time, @opType, h.H_IsNew
-- data columns
	,h.[Id]
	,h.[Email]
	,h.[Password]
	,h.[ExpiredAt]
	,h.[UserId]
	,h.[EnvironmentId]
from 
(
	select 0 as H_IsNew, t.* 
	from deleted t
	union all
	select 1 as H_IsNew, t.* 
	from inserted t
) h
order by h.Id, h.H_IsNew


END;

GO
ALTER TABLE [dom].[EmailRequest] ENABLE TRIGGER [EmailRequestHistory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dom].[MessageHistory]
   ON  [dom].[Message]
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN

	SET NOCOUNT ON;

declare @delExists bit;
declare @insExists bit;

if exists(select top 1 1 from deleted) set @delExists = 1
if exists(select top 1 1 from inserted) set @insExists = 1

declare @opType int;

if (@delExists = 1)
	if (@insExists = 1)
		set @opType = 2
	else 
		set @opType = 3
else
	if (@insExists = 1)
		set @opType = 1
	else 
		set @opType = 0
		
if (@opType = 0)
	return;	

declare @time datetime2(7) = SYSUTCDATETIME()
declare @connection_id uniqueidentifier = (select connection_id from sys.dm_exec_connections where session_id = @@SPID and parent_connection_id is null)
--declare @transaction_id bigint = (select transaction_id from sys.dm_tran_current_transaction)
declare @transaction_id bigint = (select transaction_id from sys.dm_tran_session_transactions where session_id = @@SPID)
declare @login nvarchar(128) = ORIGINAL_LOGIN()


insert into [hst_dom].[Message] ([H_ConnectionID], [H_TransactionID], [H_SessionID], [H_Login], [H_Time], [H_OperationType], [H_IsNew]
-- data columns
	,[Id]
	,[Description]
	,[Type]
	,[Locale]
	,[Name]
	,[Template]
	,[EnvironmentId])
select @connection_id, @transaction_id, @@SPID, @login, @time, @opType, h.H_IsNew
-- data columns
	,h.[Id]
	,h.[Description]
	,h.[Type]
	,h.[Locale]
	,h.[Name]
	,h.[Template]
	,h.[EnvironmentId]

from 
(
	select 0 as H_IsNew, t.* 
	from deleted t
	union all
	select 1 as H_IsNew, t.* 
	from inserted t
) h
order by h.Id, h.H_IsNew


END;

GO
ALTER TABLE [dom].[Message] ENABLE TRIGGER [MessageHistory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dom].[PermissionHistory]
   ON  [dom].[Permission]
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN

	SET NOCOUNT ON;

declare @delExists bit;
declare @insExists bit;

if exists(select top 1 1 from deleted) set @delExists = 1
if exists(select top 1 1 from inserted) set @insExists = 1

declare @opType int;

if (@delExists = 1)
	if (@insExists = 1)
		set @opType = 2
	else 
		set @opType = 3
else
	if (@insExists = 1)
		set @opType = 1
	else 
		set @opType = 0
		
if (@opType = 0)
	return;	

declare @time datetime2(7) = SYSUTCDATETIME()
declare @connection_id uniqueidentifier = (select connection_id from sys.dm_exec_connections where session_id = @@SPID and parent_connection_id is null)
--declare @transaction_id bigint = (select transaction_id from sys.dm_tran_current_transaction)
declare @transaction_id bigint = (select transaction_id from sys.dm_tran_session_transactions where session_id = @@SPID)
declare @login nvarchar(128) = ORIGINAL_LOGIN()


insert into [hst_dom].[Permission] ([H_ConnectionID], [H_TransactionID], [H_SessionID], [H_Login], [H_Time], [H_OperationType], [H_IsNew]
-- data columns
	,[Id]
	,[ApplicationId]
	,[Name]
	,[Description])
select @connection_id, @transaction_id, @@SPID, @login, @time, @opType, h.H_IsNew
-- data columns
	,h.[Id]
	,h.[ApplicationId]
	,h.[Name]
	,h.[Description]
from 
(
	select 0 as H_IsNew, t.* 
	from deleted t
	union all
	select 1 as H_IsNew, t.* 
	from inserted t
) h
order by h.Id, h.H_IsNew


END;

GO
ALTER TABLE [dom].[Permission] ENABLE TRIGGER [PermissionHistory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dom].[PermissionRoleHistory]
   ON  [dom].[PermissionRole]
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN

	SET NOCOUNT ON;

declare @delExists bit;
declare @insExists bit;

if exists(select top 1 1 from deleted) set @delExists = 1
if exists(select top 1 1 from inserted) set @insExists = 1

declare @opType int;

if (@delExists = 1)
	if (@insExists = 1)
		set @opType = 2
	else 
		set @opType = 3
else
	if (@insExists = 1)
		set @opType = 1
	else 
		set @opType = 0
		
if (@opType = 0)
	return;	

declare @time datetime2(7) = SYSUTCDATETIME()
declare @connection_id uniqueidentifier = (select connection_id from sys.dm_exec_connections where session_id = @@SPID and parent_connection_id is null)
--declare @transaction_id bigint = (select transaction_id from sys.dm_tran_current_transaction)
declare @transaction_id bigint = (select transaction_id from sys.dm_tran_session_transactions where session_id = @@SPID)
declare @login nvarchar(128) = ORIGINAL_LOGIN()


insert into [hst_dom].[PermissionRole] ([H_ConnectionID], [H_TransactionID], [H_SessionID], [H_Login], [H_Time], [H_OperationType], [H_IsNew]
-- data columns
	,[PermissionId]
	,[RoleId])
select @connection_id, @transaction_id, @@SPID, @login, @time, @opType, h.H_IsNew
-- data columns
	,h.[PermissionId]
	,h.[RoleId]
from 
(
	select 0 as H_IsNew, t.* 
	from deleted t
	union all
	select 1 as H_IsNew, t.* 
	from inserted t
) h
order by h.PermissionId, h.RoleId, h.H_IsNew


END;

GO
ALTER TABLE [dom].[PermissionRole] ENABLE TRIGGER [PermissionRoleHistory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dom].[PermissionUserHistory]
   ON  [dom].[PermissionUser]
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN

	SET NOCOUNT ON;

declare @delExists bit;
declare @insExists bit;

if exists(select top 1 1 from deleted) set @delExists = 1
if exists(select top 1 1 from inserted) set @insExists = 1

declare @opType int;

if (@delExists = 1)
	if (@insExists = 1)
		set @opType = 2
	else 
		set @opType = 3
else
	if (@insExists = 1)
		set @opType = 1
	else 
		set @opType = 0
		
if (@opType = 0)
	return;	

declare @time datetime2(7) = SYSUTCDATETIME()
declare @connection_id uniqueidentifier = (select connection_id from sys.dm_exec_connections where session_id = @@SPID and parent_connection_id is null)
--declare @transaction_id bigint = (select transaction_id from sys.dm_tran_current_transaction)
declare @transaction_id bigint = (select transaction_id from sys.dm_tran_session_transactions where session_id = @@SPID)
declare @login nvarchar(128) = ORIGINAL_LOGIN()


insert into [hst_dom].[PermissionUser] ([H_ConnectionID], [H_TransactionID], [H_SessionID], [H_Login], [H_Time], [H_OperationType], [H_IsNew]
-- data columns
	,[PermissionId]
	,[UserId]
	,[Since]
	,[Until])
select @connection_id, @transaction_id, @@SPID, @login, @time, @opType, h.H_IsNew
-- data columns
	,h.[PermissionId]
	,h.[UserId]
	,h.[Since]
	,h.[Until]
from 
(
	select 0 as H_IsNew, t.* 
	from deleted t
	union all
	select 1 as H_IsNew, t.* 
	from inserted t
) h
order by h.PermissionId, h.UserId, h.H_IsNew


END;

GO
ALTER TABLE [dom].[PermissionUser] ENABLE TRIGGER [PermissionUserHistory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dom].[RoleHistory]
   ON  [dom].[Role]
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN

	SET NOCOUNT ON;

declare @delExists bit;
declare @insExists bit;

if exists(select top 1 1 from deleted) set @delExists = 1
if exists(select top 1 1 from inserted) set @insExists = 1

declare @opType int;

if (@delExists = 1)
	if (@insExists = 1)
		set @opType = 2
	else 
		set @opType = 3
else
	if (@insExists = 1)
		set @opType = 1
	else 
		set @opType = 0
		
if (@opType = 0)
	return;	

declare @time datetime2(7) = SYSUTCDATETIME()
declare @connection_id uniqueidentifier = (select connection_id from sys.dm_exec_connections where session_id = @@SPID and parent_connection_id is null)
--declare @transaction_id bigint = (select transaction_id from sys.dm_tran_current_transaction)
declare @transaction_id bigint = (select transaction_id from sys.dm_tran_session_transactions where session_id = @@SPID)
declare @login nvarchar(128) = ORIGINAL_LOGIN()


insert into [hst_dom].[Role] ([H_ConnectionID], [H_TransactionID], [H_SessionID], [H_Login], [H_Time], [H_OperationType], [H_IsNew]
-- data columns
	,[Id]
	,[Name]
	,[Description]
	,[IsDefault])
select @connection_id, @transaction_id, @@SPID, @login, @time, @opType, h.H_IsNew
-- data columns
	,h.[Id]
	,h.[Name]
	,h.[Description]
	,h.[IsDefault]
from 
(
	select 0 as H_IsNew, t.* 
	from deleted t
	union all
	select 1 as H_IsNew, t.* 
	from inserted t
) h
order by h.Id, h.H_IsNew


END;

GO
ALTER TABLE [dom].[Role] ENABLE TRIGGER [RoleHistory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dom].[RoleUserHistory]
   ON  [dom].[RoleUser]
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN

	SET NOCOUNT ON;

declare @delExists bit;
declare @insExists bit;

if exists(select top 1 1 from deleted) set @delExists = 1
if exists(select top 1 1 from inserted) set @insExists = 1

declare @opType int;

if (@delExists = 1)
	if (@insExists = 1)
		set @opType = 2
	else 
		set @opType = 3
else
	if (@insExists = 1)
		set @opType = 1
	else 
		set @opType = 0
		
if (@opType = 0)
	return;	

declare @time datetime2(7) = SYSUTCDATETIME()
declare @connection_id uniqueidentifier = (select connection_id from sys.dm_exec_connections where session_id = @@SPID and parent_connection_id is null)
--declare @transaction_id bigint = (select transaction_id from sys.dm_tran_current_transaction)
declare @transaction_id bigint = (select transaction_id from sys.dm_tran_session_transactions where session_id = @@SPID)
declare @login nvarchar(128) = ORIGINAL_LOGIN()


insert into [hst_dom].[RoleUser] ([H_ConnectionID], [H_TransactionID], [H_SessionID], [H_Login], [H_Time], [H_OperationType], [H_IsNew]
-- data columns
	,[RoleId]
	,[UserId])
select @connection_id, @transaction_id, @@SPID, @login, @time, @opType, h.H_IsNew
-- data columns
	,h.[RoleId]
	,h.[UserId]
from 
(
	select 0 as H_IsNew, t.* 
	from deleted t
	union all
	select 1 as H_IsNew, t.* 
	from inserted t
) h
order by h.RoleId, h.UserId, h.H_IsNew


END;

GO
ALTER TABLE [dom].[RoleUser] ENABLE TRIGGER [RoleUserHistory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dom].[SmsRequestHistory]
   ON  [dom].[SmsRequest]
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN

	SET NOCOUNT ON;

declare @delExists bit;
declare @insExists bit;

if exists(select top 1 1 from deleted) set @delExists = 1
if exists(select top 1 1 from inserted) set @insExists = 1

declare @opType int;

if (@delExists = 1)
	if (@insExists = 1)
		set @opType = 2
	else 
		set @opType = 3
else
	if (@insExists = 1)
		set @opType = 1
	else 
		set @opType = 0
		
if (@opType = 0)
	return;	

declare @time datetime2(7) = SYSUTCDATETIME()
declare @connection_id uniqueidentifier = (select connection_id from sys.dm_exec_connections where session_id = @@SPID and parent_connection_id is null)
--declare @transaction_id bigint = (select transaction_id from sys.dm_tran_current_transaction)
declare @transaction_id bigint = (select transaction_id from sys.dm_tran_session_transactions where session_id = @@SPID)
declare @login nvarchar(128) = ORIGINAL_LOGIN()


insert into [hst_dom].[SmsRequest] ([H_ConnectionID], [H_TransactionID], [H_SessionID], [H_Login], [H_Time], [H_OperationType], [H_IsNew]
-- data columns
	,[Id]
	,[Phone]
	,[Password]
	,[ExpiredAt]
	,[UserId]
	,[EnvironmentId])
select @connection_id, @transaction_id, @@SPID, @login, @time, @opType, h.H_IsNew
-- data columns
	,h.[Id]
	,h.[Phone]
	,h.[Password]
	,h.[ExpiredAt]
	,h.[UserId]
	,h.[EnvironmentId]
from 
(
	select 0 as H_IsNew, t.* 
	from deleted t
	union all
	select 1 as H_IsNew, t.* 
	from inserted t
) h
order by h.Id, h.H_IsNew


END;

GO
ALTER TABLE [dom].[SmsRequest] ENABLE TRIGGER [SmsRequestHistory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dom].[TokenRegistrationHistory]
   ON  [dom].[TokenRegistration]
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN

	SET NOCOUNT ON;

declare @delExists bit;
declare @insExists bit;

if exists(select top 1 1 from deleted) set @delExists = 1
if exists(select top 1 1 from inserted) set @insExists = 1

declare @opType int;

if (@delExists = 1)
	if (@insExists = 1)
		set @opType = 2
	else 
		set @opType = 3
else
	if (@insExists = 1)
		set @opType = 1
	else 
		set @opType = 0
		
if (@opType = 0)
	return;	

declare @time datetime2(7) = SYSUTCDATETIME()
declare @connection_id uniqueidentifier = (select connection_id from sys.dm_exec_connections where session_id = @@SPID and parent_connection_id is null)
--declare @transaction_id bigint = (select transaction_id from sys.dm_tran_current_transaction)
declare @transaction_id bigint = (select transaction_id from sys.dm_tran_session_transactions where session_id = @@SPID)
declare @login nvarchar(128) = ORIGINAL_LOGIN()


insert into [hst_dom].[TokenRegistration] ([H_ConnectionID], [H_TransactionID], [H_SessionID], [H_Login], [H_Time], [H_OperationType], [H_IsNew]
-- data columns
	,[Id]
	,[UserId]
	,[AccessToken]
	,[IssuedAt]
	,[ExpiredAt])
select @connection_id, @transaction_id, @@SPID, @login, @time, @opType, h.H_IsNew
-- data columns
	,h.[Id]
	,h.[UserId]
	,h.[AccessToken]
	,h.[IssuedAt]
	,h.[ExpiredAt]
from 
(
	select 0 as H_IsNew, t.* 
	from deleted t
	union all
	select 1 as H_IsNew, t.* 
	from inserted t
) h
order by h.Id, h.H_IsNew


END;

GO
ALTER TABLE [dom].[TokenRegistration] ENABLE TRIGGER [TokenRegistrationHistory]
GO

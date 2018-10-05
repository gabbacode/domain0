#### Domain0 user authentication service

>

## Installation

1. prepare a database

2. deploy database
```
run deploy script: Scripts\database.sql
```
3. fill .config params

4. add full path to ssl certificate and password to config

5. configure logs

6. make a test run

5. install domain0 as service
```
Domain0.WinService.exe install -username:user -password:pas
```

---

# Domain0 user authentication service

**Description**:  Easy authenticate users with login passwords and receive JWT access token and refresh token for your application with user permissions and other grants.

Other things to include:

  - **Technology stack**: [Topshelf](https://github.com/Topshelf/Topshelf), [NancyFX](http://nancyfx.org), [Autofac](https://autofac.org), [FastSql](https://github.com/gerakul/FastSql), [Monik](https://github.com/Totopolis/monik)
  - **Status**:  Under development [CHANGELOG](CHANGELOG.md).

**Screenshot**: 

![](/screenshot.png)


## Dependencies

Software running under Windows with net462

## Installation

[INSTALL](INSTALL.md).

## Configuration



## Usage


## How to test the software


## Getting help

If you have questions, concerns, bug reports, etc, please file an issue in this repository's Issue Tracker.

## Getting involved

[CONTRIBUTING](CONTRIBUTING.md).


----

## Open source licensing info
1. [TERMS](TERMS.md)
2. [LICENSE](LICENSE)
3. [CFPB Source Code Policy](https://github.com/cfpb/source-code-policy/)


----

# Why?
Lately we have been facing an intermitent network issue, which is happening only on s390x arch. [Link to drone issue](https://drone-publish.rancher.io/rancher/ingress-nginx/149/2/2)
This issue has been replicated multiple times on dev drone environments.
Mainly it happens performing `docker push` actions or other kind of operations where networking is used.

This repo is a simplification of the code on this repo https://github.com/rancher/ingress-nginx/tree/nginx-1.2.0-hardened6

# Background
Some time ago, one of the bases images used on the pipelines was changed to alpine 1.14
This version of alpine brought with it changes of *faccessat2* [Release Note](https://wiki.alpinelinux.org/wiki/Release_Notes_for_Alpine_3.14.0#faccessat2)

In order to be able to run properly again the pipelines on s390x we perform the modification detailed on the step number 3. 

# Tests

## Setting up the environment
In order to test this code, you should:

``` 
git clone https://github.com/Anarkis/s390x-poc.git
docker run -v YOUR_GIT_PATH:/test  -v /var/run/docker.sock:/var/run/docker.sock -ti --privileged rancher/dapper:v0.5.7 sh
>> Inside the docker
cd /test/
dapper ci
```
### Running in other arch rather than s390x
You should change the ENV `DAPPER_HOST_ARCH` inside the `Dockerfile.dapper` to fit the arch that you are working on

## Expected results
We consider a **failure** when we see an output like this:
```
+ echo 'RUNNING BUILD'
RUNNING BUILD
+ ARCH=s390x
+ make build
./build.sh
make: /bin/bash: Operation not permitted
make: *** [Makefile:6: build] Error 127
```
( Makefile can not execute ./build.sh )

We consider a **success** if we see an output like this:
```
RUNNING BUILD
+ ARCH=s390x
+ make build
./build.sh
+ echo 'Executing build.sh'
Executing build.sh
+ echo 'SUCCESS!!!'
SUCCESS!!!
```
( Makefile can execute ./build.sh, and the script is executed properly)

### Docker images involved

#### rancher/hardened-build-base
- alpine 3.15.4
- libseccomp libseccomp-2.5.2-r0
- scmp_sys_resolver faccessat2 > 439
- docker version 20.10.14 build a224086349269551becacce16e5842ceeb2a98d6

#### s390x/docker:18.06
- alpine 3.9.4
- NO libseccomp
- NO scmp_sys_resolver
- Docker version 18.06.3-ce, build d7080c1

#### rancher/dapper:v0.5.7
- alpine 3.9.4
- NO libseccomp
- NO scmp_sys_resolver
- Docker version 18.06.3-ce, build d7080c1

### VM 1
```
ARCH x86
VM on SLES 15-SP3
libseccomp2: libseccomp2-2.5.3-150300.10.8.1.x86_64
Docker version 20.10.12-ce, build 459d0dfbbb51
```
This config works

### VM2
```
ARCH s390x
VM on SLES 15-SP3
libseccomp2: libseccomp2-2.5.3-150300.10.8.1.s390x
Docker version 20.10.12-ce, build 459d0dfbbb51
```
This config **does not** work

### VM3
```
ARCH s390x
VM on SLES 15-SP3
libseccomp2: libseccomp2-2.4.1-3.3.1.s390x
Docker version 20.10.11, build dea9396
Applied changes described on Alpine 3.14 release
```
This config works



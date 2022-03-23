
# Multi-Stage Image Creation
# syntax=docker/dockerfile:1

FROM golang:1.16 AS golang
ARG GO_PATH=/go/src/github.com/alexellis/href-counter/
WORKDIR $GO_PATH
RUN go get -d -v golang.org/x/net/html && go mod init
COPY app.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

FROM alpine:latest
ARG GO_PATH=/go/src/github.com/alexellis/href-counter/
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=golang $GO_PATH/app ./
CMD ["./app"]

# - The COPY --from=golang line copies just the built artifact from the previous
# stage into this new stage.
# - The Go SDK and any other intermediate artifacts are left behind and not saved
# in the final image.

# WARNING!
# - Don't use your root directory "/" as the PATH for your build context, as it causes the build to
# transfer the entire contents of your hard drive to the Docker daemon.

# The build is run by the Docker daemon, not by the CLI.
# - The first thing a build process does is to send the entire context (recursively) to the Docker
# daemon.
# - In most cases, it's best to start with an empty directory as context and keep your Dockerfile
# in that directory; add only the files needed for building the Dockerfile!

# - Using a file in the build context, the Dockerfile refers to the file specified in an instruction
# for instance; a COPY instruction.
# - To increase the build performance, exclude files and directories by adding a .dockerignore file
# to the context directory.

# Traditionally the Dockerfile is called "Dockerfile" and located in the root of the context.
# Use the -f flag with "docker build" to point to a Dockerfile anywhere in your file system.
# You may specify a tag "-t" to name the new image.

# docker build -f /path/dev.Dockerfile -t go-web-app .

# Tagging the image into multiple repositories after the build, add multiple -t parameters.
# docker build -t sabitk/go-app:v1.1.1 -t fallback-repo-sabitk/go-app:latest .





# FORMAT
# INSTRUCTION argumetns
# 
# - The instrcution isn't case-sensitive, however convention is for them to be UPPERCASE to
# distinguish them from arguments easily.
#
# - A Dockerfile must begin with a FROM instrcution, this may be after parser directives, comments
# and globally scoped ARGs
# - The FROM instruction specifies the Parent Image from which you're building
# - FROM may only be preceded by one or more ARG instructions, which declare arguments
# that are used in FROM lines in the Dockerfile
# - Any line which starts with "#" is considered as a comment line
#
# Example:
#
# # This's a comment line
# RUN echo 'This's a part of echo # command'
# # This's another comment line
# RUN echo hello world
#
# NOTE on Whitespace
# - For backward compatibility leading whitespace before comments # and instructions ( RUN exc.)
# are ignored but discouraged, leading whitespace isn't preserved in these cases.
#
# Example:
#
#       # comment-line
#   RUN echo nice
# RUN echo shirt
#
# same as below
#
# # comment-line
# RUN echo nice
# RUN echo shirt
#
# - Whitespace in instruction arguments such as commands following RUN are preserved
# Example:
# 
# RUN echo "\
#       hello \
#       world
#
# output:       hello        world
#
# 
# 
# PARSER DIRECTIVES
# - Parser directives are optional and affect the way in which subsequesnt lines in a Dockerfile
# are handled.
# - They don't add layers to build and won't be shown as a build step.
# - # directive=value is the form of parser directive.
#
# - Once a comment, empty line or builder instruction has been processed Docker no longer looks
# for parser directives. Instead it treats anything formatted as a parser directive as a comment
#
# - Thus, all parser directives must be at the very top of a Dockerfile! 
# 
# Example:
# 
# # This's a comment line
# # directive=value        --> this line will be treaded as a comment line!
# FROM image:version
#
# Example:
# 
# # unknowndirective=value --> The unknowndirective is treated as a comment
# # directive=value        --> so that this line will be treated as a comment either!
# FROM image:version
#
# Example:
# - Non line-breaking whitespace is permitted in a parser directive; hence the following lines 
# are all treaded identically
#
# #directive=value
# # directive =value
# #     directive= value 
# # directive = value
# #     dIrecTIVe =value
#
# FROM image:version
#
#
# syntax, escape are valid parser directives
# - syntax feature is only available when using the BuildKit backend.
#
# # syntax=[remote image reference]
# # syntax = docker/dockerfile:1
# # syntax=docker.io/docker/dockerfile:1
# # syntax=example.com/user/repo:tag@sha256:v2
#
# escape=\ or escape=`
#
# - The "escape" directive sets the character used to escape characters in a Dockerfile. If not
# specified the default escape char is "\".
#
# - Setting escape char to "`" is especially usefule on Windows, where \ is the directory path
# seperator, "`" is consistent with Windows PowerShell. 
# 
# Example:
# 
# # syntax=docker/dockerfile:1
# 
# FROM microsoft/nanoserver
# COPY testfile.txt c:\     --> will throw error
# RUN dir c:\               --> will throw error
#
# Example:
# 
# # syntax=docker/dockerfile1
# # escape=`
#
# FROM misrosoft/nanoserver
# COPY testfile.txt c:\     
# RUN dir c:\


# ENV
#
# - Environment variables can alos be used in certain instructions as variables to be interpreted
# by the Dockerfile.
#
# - Envrionment variables are notated in the Dockerfile either with $name or ${name}
# - Brace syntax is typically used to address issues with variabl names with no whitespace
# like ${foo}_bar.
#
# The ${variable_name} syntax also supports a few of the standard bash modifiers as specified below:
# 
# - ${variable:-word} if variable is set then the result will be that value, otherwise "word" will
# be the result.
#
# - ${variable:+word} if variable is set then the "word" will be the result, otherwise result will
# be an empty string.
#
# Escaping is possible by adding a "\" before the variable \$foo or \${foo}
#
# Example:
#
# # syntax=docker/dockerfile:1
#
# FROM nginx:latest
# ENV FOO=/bar
# WORKDIR ${FOO}    # WORKDIR /bar
# ADD . $FOO        # ADD . /bar
# COPY \$FOO /bar   # COPY $FOO /bar
# 
# Environment vars are supported by the following list of instructions in the Dockerfile:
# ADD, COPY, ENV, EXPOSE, FROM, LABEL, STOPSIGNAL, USER, VOLUME, WORKDIR, ONBUILD
#
# Example:
# 
# ENV path=/src
# ENV path=/usr dpath=$path  # path=/usr dpath=/src
# ENV tpath=$path            # tpath=/usr



# .dockerignore
# 
# - Before the docker CLI sends the context to the docker deamon it looks for a file named 
# .dockerignore in the root directory of the context.
#
# - If the file exists the CLI modifies the context to exclude files and directories that match
# patterns in .dockerfile.
#
# - This helps to avoid redundant sending large or sensitive files and directories to the daemon
# and potentially adding them to images using ADD or COPY.
#
# Example:
#
# # comment     --> ignored comment line
# */temp*       --> exclude files and directories whose names start with temp in any immediate
#                   subdirectory of the root
#                   (/somedir/temporal.txt) or (/somedir/temp) are excluded including subdirs.
#
# */*/temp*     --> exclude files and directories starting with temp from any subdirectory that
#                   is two levels below the root
#                   (/somedir/subdir/temporary.txt) is excluded
#           
# temp?         --> exclude files and directories in the root directory whose names are a one-char
#                   extension of temp.
#                   (/tempa and /tempb) are excluded
#
# **/*.go       --> exlude all files that end with .go that are found in all directories, including
#                   the root of the build context.
#
# *.md
# !README.md    --> ! make exceptions to exlusions, all md files except README.md
#
# *.md
# !README*.md   --> exclude all .md files, include !README*.md files except README-secret.md
# README-secret.md    
#
# .dockerignore
# *Dockerfile*  --> exclude Dockerfile and .dockerignore, these files are still sent to the daemon 
#                   because it needs them to do its job but the ADD and COPY instructions don't
#                   copy them to the image.
#
# NOTE
# For historical reasons, the pattern . is ignored


# FROM
# - The instruction initializes a new build stage and sets the Base Image for subsuquent instructions.
# - A valid Dockerfile must start with a FROM instruction.
#
# FROM [--platform=<platform>] <image>[@<digest> or :<tag>] [AS <name>]
#  
# - ARG is the only instruction that may precede FROM in the Dockerfile.
#
# - FROM may appear multiple times within a single Dockerfile to create multiple images or use one
# build stage as a dependency for another.
#
# - Make a note of the last image ID output ( AS <name> ) by the commit before each new FROM instruction.
# each FROM instruction clears any state created by previous instructions.
# 
# - Optionally a name can be given to a new build stage by adding "AS name" to the FROM instruction.
# The name can be used in consequent FROM and COPY --from=<name> instructions.
#
# - The "tag" or "digest" values are optional, if you omith either of them "tag=latest" by default.
#
#
# NOTE
# - The optional --platform flag can be used to specify the platform of the image in case FROM
# references a multi-platform image.
#  ___________________________________________________
# |                                                   |
# | FROM --platform=$BUILDPLATFORM alpine:3.2 AS bld  |                                             
# | ARG TARGETPLATFORM                                |
# | RUN compile --target=$TARGETPLATFORM -o /bin      |
# |                                                   |
# | [FROM (--platform=$TARGETPLATFORM by default)]    |
# | FROM alpine                                       |
# | COPY --from=bld /bin /out/bin                     |
# |                                                   |
# | # building an image for two target platforms      |
# | docker build --platform=linux/amd64,linux/arm64 . |
# |                                                   |   
# | The first builder will pull down the Apline image |
# | for AMD64 install the build dependencies and copy |
# | over the source.                                  |
# |                                                   |
#  ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
# IMPORTANT
# - When building a multi-platform image from a Dockerfile, effectively your Dockerfile gets built
# once for eache platform. At the end of the build all of these images are merget together into a 
# single multi-platform image!
#
# Example:
# 
# FROM alpine
# RUN echo "hi" > /hello
#
# - In the case of a simple Dockerfile like this, that is build for two architectures, BuildKit will
# pull two different versions of the alpine image, one containing x86 binaries and another containing
# arm64 binaries and then run their respective shell binary on each of them
#
#
#
# - "linux/amd64, linux/arm64 or windows/amd64"
#
# - By default the target platform of the build request is used, global build arguments can be used
# in the value of this flag.
#
# ARGs global scope on BuildKit, following ARG variables are set automatically:
# 
# - Docker predefines a set of ARG variables with information on the platform of the node performing
# the build (build platform) and on the platform of the resulting image (target platform), the target
# platform can be specified with the --platform flag on docker build .
#
# - TARGETPLATFORM : platform of the build result ( linux/amd64 exc.)
# - TARGETOS       : OS component of TARGETPLATFORM
# - TARGETARCH     : architecture component of TARGETPLATFORM
# - TARGETVARIANT  : variant component of TARGETPLATFORM
# 
# - BUILDPLATFORM  : platform of the node performing the build.
# - BUILDOS        : OS component of BUILDPLATFORM 
# - BUILDARCH      : architecture component of BUILDPLATFORM 
# - BUILDVARIANT   : variant component of BUILDPLATFORM 
#
# These arguments are defined in the global scope so are not automatically available inside build
# stages or for your RUN commands, to expose one of these arguments inside the build stage redefine
# it without value.
# 
# Example:
# 
# FROM alpine
# ARG TARGETPLATFORM
# RUN echo "This's for $TARGETPLATFORM"
#
#
# ARG & FROM interaction
# 
# - ARG declared before a FROM is outside of a build stage so it can't be used in any instruction
# after a FROM; to use the default value of an ARG declared before the first FROM use an ARG instruction
# without a value inside of a build stage
#
# ARG VERSION=latest
# FROM busybox:$VERSION
# ARG VERSION
# RUN echo $VERSION > version.txt 



# RUN (buildtime instruction)
# 
# > RUN <command> ( shell form /bin/sh -c "<command>" ) 
# > RUN ["executable","param1","param2"] 
# 
# - In the shell you may use a "\" to continue a single RUN instruction onto the next line.
#
# RUN /bin/bash -c 'source $HOME/.bashrc; \
# echo $HOME'
#
# same as
#
# RUN /bin/bash -c 'source $HOME/.bashrc; echo $HOME'
#
#
# 
# - The RUN instruction will execute any commands in a new layer on top of the current image and 
# commit the results.
# - The resulting committed image will be used for the next step in the Dockerfile
#
# - Layering RUN instructions and generating commits conforms to the core concepts of Docker where
# commits are cheap and containers can be created from any point in an image's history, like a
# source control
#
# - The exec form makes it possible to avoid shell string munging and to RUN commands using a
# base image that doesn't contain the specified shell executable.
#
# - Default shell for the "shell form" can be changed using the SHELL command.
# 
# - Unlike the shell form the "exec form" doesn't invoke a command shell, this means that normal
# shell processing doesn't happen.
#
# - For example; RUN ["echo","$HOME"] won't do variable substitution on $HOME, if you want both shell
# and exec form run together use RUN ["sh","-c","echo $HOME"]; it's the shell doint the environment
# variable expansion, not docker!
# 
# NOTE
# - In the JSON form it's essential to escape backslashes, this's relevant on Windows where the backslash
# is the path separator.
#
# RUN ["c:\windows\system32\tasklist.exe"]    --> ERROR!
# RUN ["c:\\windows\\system32\\tasklist.exe"] --> WELL DONE!
#
# IMPORTANT
#
# - The cache for RUN instructions isn't invalidated automatically during the next build; the cache 
# for an instruction as "RUN apt-get dist-upgrage -y" will be reused during the next build.
#
# - The cache for RUN instructions can be invalidated by using the "--no-cache" flag
#   ( docker build --no-cache . ) 
#  ________________________________________________________________________________
# |                                                                                |
# | The cache for RUN instructions can be invalidated by ADD and COPY instructions |
# |                                                                                | 
#  ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾





# SHELL
# 
# > SHELL ["executable","parameters"]
# 
# - Default shell on Linux   : ["/bin/sh","-c"] 
# - Default shell on Windows : ["cmd","/S","/C"] or ["powershell","-command"]
# 
# - Each SHELL instruction overrides all previous SHELL instructions and affects all following 
# instructions.
#
# Example:
#
# FROM microsoft/windowsservercore
#
# # Executed as cmd /S /C echo default
# RUN echo default
#
# # Executed as cmd /S /C powershell -command Write-Host Default
# RUN powershell -command Write-Host Default
#
# # Executed as powershell -command Write-Host hello
# SHELL ["powershell","-command"]
# RUN Write-Host hello
#
# # Executed as cmd /S /C /V:10 echo hello
# SHELL ["cmd","/S","/C","/V:10"]
# RUN echo hello
# 
#
# Example:
# 
# # escape=`
# 
# FROM microsoft/nanoserver
#
# SHELL ["powershell","-command"]
# RUN New-Item -ItemType Directory C:\Example
# COPY Execute-MyCmdlet.ps1 c:\example\ 
# RUN c:\example\Execute-MyCmdlet -sample 'hi world'



# CMD (runtime instruction)
# 
# > CMD ["executable","param1","param2"] : exec form, preferred form
# > CMD ["param1","param2"]              : default parameters to ENTRYPOINT
# > CMD command param1 param2            : shell form
# 
# NOTE
# - The exec form is parsed as a JSON array, which means that you must use double-quotes ["] not
# single quotes [']
#
# 
# - There can only be one CMD instruction in a Dockerfile, if you list more than one CMD then only
# the last CMD will take affect.
#
# - Tha main purpose of a CMD is to provide defaults ofr an executing container; these defaults can
# include an executable or the can omit the executable in which case you must spcify ENTRYPOINT
#
# Example:
# 
# FROM apline:latest
# ENTRYPOINT ["/bin/bash","-c"] : you may overrite this on "docker run --entrypoint"
# CMD ["ls","-al","/bin"]       : you may overrite this on "docker run .. image CMD"
#
# Example:
#
# FROM ubuntu:latest
# CMD echo "Command test" | wc -l : docker run .. image /bin/sh -c "echo 'Command test' | wc -l"
#
# Example:
#
# FROM ubuntu:latest
# CMD ["/usr/bin/wc","--help"] : docker run .. image /usr/bin/wc --help



# LABEL
# - The LABEL instruction adds metadata to an image, a LABEL is a key-value pair; to include spaces
# within a LABEL value, use quotes and backslashes as you would in command-line parsing
# 
# Example:
#
# LABEL "com.example.vendor"="ACME Incorporated"
# LABEL com.example.label-with-value="foo"
# LABEL version="1.0"
# LABEL description="This will be a long line \
# please keep typing."
#
# Multiple LABELs in a single instruction
# LABEL label1="val1" label2="val2" \
#       label2="val3" label4="val4" 



# EXPOSE
# 
# - The inscturtion informs Docker that the container listens on the specified network ports at runtime
# - You may specify whether the port listens on TCP / UDP, default is TCP if not specified.
#
# - The EXPOSE instruction doesn't actually publish the port, it functions as a type of documentation
# between the person who builds the image and the person who runs the container.
# - To actually publish the port when running the container, use the "-p" or flag on docker run to publish
# and map one or more ports, or "-P" flag to publish all exposed ports and map them to high-order ports
#
# EXPOSE 53/udp
#
# To expose both TCP and UDP, include two lines:
#
# EXPOSE 80/tcp
# EXPOSE 80/udp
#
# - if you run command "docker run -P" the port will be exposed once for TCP and UDP, mind that "-P"
# uses an ephemeral high-order host port on the host, so the port won't be the same for TCP and UDP
#
# - Regardless of the EXPOSE settings, you can override them at runtime by using the -p flag.
#
# > docker run -p 80:80/tcp -p 80:80/usp -p 1125-1130:1225-1230/udp -p 12356-12360:8080



# ENV
#
# - The ENV instruction sets the environment variable <key> to <value>, this value will be in the environment
# for all consequtive instructions in the build stage and can be replaced inline in many as well.
#
# - The value will be interpreted for other environment variables so quote characters will be removed
# if they're not escaped; like command-line parsing, quotes and backslashes can be used to include
# spaces and whitin values.
#
# Example:
#
# ENV AUTHOR="Terry Johannes"
# ENV MY_CAT=Fluffy\ The\ Cat
# ENV MY_TORTOISE=Coco
# ENV VERSION v1.1.1
#
# Example:
#
# ENV AUTHOR="Terry Johannes" \
#     MY_CAT=Fluffy\ The\ Cat \
#     MY_TORTOISE=Coco \
#
# - The environment variables set using ENV will persist when a container is run from the resulting
# image, you may change them using "docker run --env <key>=<value> ... "
#
# NOTE
# - If an environment variable is only needed during build and not in the final image, consider 
# setting a value for a single command:
# 
# > RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y ...
#
# - or use ARG, which isn't persisted in the final image
#
# > ARG DEBIAN_FRONTEND=noninteractive
# > RUN apt-get update && apt-get install -y ...



# ADD
#
# > ADD [--chown=<user>:<group>] <src>... <dest>
# > ADD [--chown=<user>:<group>] ["<src>",... "<dest>"]
#
# - "--chown" only works for Linux!
#
# - The ADD instruction copies new files, directories or remote file URLs from <src> and adds them to
# the filesystem of the image at the path <dest>.
#
# - Multiple <src> resources may be specified but if they're files or directories, their paths are
# interpreted as relative to the source of the context of the build.
#
# Example:
#
# ADD hom* /usr/home/ 
# ADD hom?.txt /usr/home/
#
# - The <dest> is an absolute path or a path relative to WORKDIR, into which the source will be copied
# in the destination container.
#
# ADD dummy.txt relativeDir/  : ADD <relative-to-build-context> <relative-to-WORKDIR>
# ADD dummy.txt /absoluteDir/ : absolute destination path
#
# - When adding files or directories that contain special characters ( such as [ and ] ), you need to
# escape those paths following the Golang rules to prevent them from being treated as a matching pattern
#  ___________________________________________________
# |                                                   |              
# | To add a file named arr[0].txt, use the following |
# | ADD arr[[]0].txt /absoluteDir/                    |  
# |                                                   |
#  ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
#
# - ALL new files and directories are created with UID and GID of 0, unless the optional --chown flag
# specifies a given username, groupname or UID/GID combination.( /etc/passwd & /etc/group )
#
# - Providing a username without groupname or a UID without GID will use the same numeric
# UID as the GID

# Example:
# 
# ADD --chown:55:netdev files* /somedir/    : --chown:55:netdev  : --chown:ID:GroupName
# ADD --chown=bin files* /somedir/          : --chown:bin:bin    : --chown:UserName:GroupName
# ADD --chown=1 files* /somedir/            : --chown:1:1        : --chown:UID:GID
# ADD --chown=10:11 files* /somedir/        : --chown:10:11      : --chown:UID:GID
#
# - If the container root filesystem doesn't contain either /etc/passwd or /etc/group files and 
# either user or group names are used in the --chown flag, the build will fail on the ADD operation
#  _____________________________________________________________________________________________
# |                                                                                             |
# | Using numeric IDs requires no lookup and won't depend on container root filesystem content. |
# |                                                                                             |
#  ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾ 
#
# - In the case where <src> is a remote file URL, the destination will have permissions of 600.
#
# - if the remote file being retrieved has an HTTP Last-Modified header, the timestamp from that 
# header will be used to set the "mtime" on the destination file.
#
# - However, like any other file processed during an ADD, mtime won't be included in the determination
# of whether or not the file has changed and the cache should be updated. 
#
#
# NOTE
# - If you build by passing a Dockerfile through STDIN (docker build - < archive.tar.gz) there's no
# build context so the Dockerfile can only contain a URL based ADD instruction.
#
# -If your URL files are protected using authentication, you need to use RUN wget, RUN curl or use
# another tool from whithin the container as the ADD instruction doesn't support authentication.
#
# 
# ADD rules:
#
# - The <src> path must be inside the context of the build; you can't "ADD ../usr/temp", because the
# first step of a "docker build" is to send the context directory (+subdirectories) to the docker daemon
#
# - If <src> is a URL and <dest> doesn't end with a trailing slash then a file is downloaded from the
# URL and copied to <dest>. (ADD <url> /dest)
#
# - If <src> is a URL and <dest> does end with a trailing slash the the filename is inferred from the 
# URL and the file is downloaded to <dest>/<filename>
#  _____________________________________________________________________________
# |                                                                             |
# | ADD http://example.com/foo /download/ : would create a file "/download/foo" |
# |                                                                             |
#  ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
# - If <src> is a directory, the entire contents of the directory are copied (not the directory's itself)
# including filesytem metadata.
#
# - If <src> is a local tar archive in a recognize compression format then it's unpacked as a directory
# resources from remote URLs are compressed, when a directory is copied or unpacked it has the same
# behaviour as tar -x, the result is the union of:
#   - Whatever existed at the destination path 
#   - The contents of the source tree, with conflicts resolved on a file-by-file basis.
#
#
# - If <src> is any other kind of file, it's copied individually along with its metadata. In this case
# if <dest> ends with a "/" it'll be considered a directory and the contents of <src> will be written
# at <dest>/<src>.
#
# - If <dest> doesn't end with a "/" it'll be considered a regular file and the contents of <src> will
# be written at <dest>
#
# - If <dest> doesn't exist, it's created along with all missing directories in its path.




# COPY
#
# > COPY [--chown=<usecir>:<group>] <src>... <dest>
# > COPY [--chown=<user>:<group>] ["<src>",... "<dest>"]
#
# - "--chown" only works for Linux!
#
# - The COPY instruction copies new files, directories or remote file URLs from <src> and adds them to
# the filesystem of the image at the path <dest>.
#
# - Multiple <src> resources may be specified but if they're files or directories, their paths are
# interpreted as relative to the source of the context of the build.
#
# Example:
#
# COPY hom* /usr/home/ 
# COPY hom?.txt /usr/home/
#
# - The <dest> is an absolute path or a path relative to WORKDIR, into which the source will be copied
# in the destination container.
#
# COPY dummy.txt relativeDir/  : COPY <relative-to-build-context> <relative-to-WORKDIR>
# COPY dummy.txt /absoluteDir/ : absolute destination path
#
# - When adding files or directories that contain special characters ( such as [ and ] ), you need to
# escape those paths following the Golang rules to prevent them from being treated as a matching pattern
#  ___________________________________________________
# |                                                   |              
# | To add a file named arr[0].txt, use the following |
# | COPY arr[[]0].txt /absoluteDir/                   |  
# |                                                   |
#  ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
#
# - ALL new files and directories are created with UID and GID of 0, unless the optional --chown flag
# specifies a given username, groupname or UID/GID combination.( /etc/passwd & /etc/group )
#
# - Providing a username without groupname or a UID without GID will use the same numeric
# UID as the GID
#
# Example:
# 
# COPY --chown:55:netdev files* /somedir/    : --chown:55:netdev  : --chown:ID:GroupName
# COPY --chown=bin files* /somedir/          : --chown:bin:bin    : --chown:UserName:GroupName
# COPY --chown=1 files* /somedir/            : --chown:1:1        : --chown:UID:GID
# COPY --chown=10:11 files* /somedir/        : --chown:10:11      : --chown:UID:GID
#
# - If the container root filesystem doesn't contain either /etc/passwd or /etc/group files and 
# either user or group names are used in the --chown flag, the build will fail on the COPY operation
#  _____________________________________________________________________________________________
# |                                                                                             |
# | Using numeric IDs requires no lookup and won't depend on container root filesystem content. |
# |                                                                                             |
#  ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾ 
# 
# COPY rules:
#
# - If <src> is any other kind of file, it's copied individually along with its metadata, in this case
# if <dest> ends with a trailing slash / it'll be considered a directory and the contents of <src>
# will be written at <dest>/<src>
#
# - If multiple <src> resources are specified either directly or due to the use of a wildcard then
# <dest> must be a directory and it must end with a slash /
# (COPY dummy.txt scheduler.sh /etc/storage
#
# - If <dest> doesn't end with a trailing slash it'll be considered a regular file and the contents
# of <src> will be written at <dest>.
#
# - If <dest> doesn't exist it's created along with all missing directories in its path.
#
# NOTE
#
# - The first encountered COPY instruction will invalidate the cache for all following instructions
# from the Dockerfile, if the contents of <src> have changed; this includes invalidating the cache
# for RUN instructions.



# ENTRYPOINT
# 
# > ENTRYPOINT ["executable","param1","param2"]
# > ENTRYPOINT command param1 param2 : default SHELL will be in play.
#
# - Command-line arguments to "docker run image CMD" will be appended after all elements in an exec
# form ENTRYPOINT and will override all elements specified using CMD in Dockerfile.
#
# - You may override the ENTRYPOINT instruction usind the "docker run --entrypoint" flag
#
# - The shell form prevents any CMD or run command line arguments from being used, but has the disadvantage
# that your ENTRYPOINT will be started as a subcommand of /bin/sh -c which doesn't pass signals!
#
# - This means, the executable won't be the container's PID 1 and won't recieve Unix signals so your
# executable won't recieve a SIGTERM from "docker stop <container>"
#
# Only the last ENTRYPOINT instruction in the Dockerfile will have an effect.
#
# Example:
#
# FROM ubuntu
# ENTRYPOINT ["sleep"]
# CMD ["3"]
#
# Example:
# 
# FROM debian:stable
# RUN apt-get update && apt-get install -y --force-yes apache2
# EXPOSE 80 443
# VOLUME ["/var/www","/var/log/apache2/","/etc/apache2"]
# ENTRYPOINT ["usr/sbin/apache2ctl","-D","FOREGROUND"]
#
#
# - If you need to write a starter scrping for a single executable, you can ensure that the final
# executable receives the Unix signals by using "exec" and "gosu" commands
#  _____________________________________________
# |                                             |
# | #!/usr/bin/env bash                         |
# | set -e                                      |
# |                                             |
# | if [ "$1" = 'postgres' ]; then              |
# |     chown -R postgres "$PGDATA"             |
# |                                             |
# |     if [ -z "$(ls -A "$PGDATA")" ]; then    |
# |         gosu postgres initdb                |
# |     fi                                      |
# |                                             |
# |     exec gosu postgres "$@"                 |    
# |                                             |    
# | fi                                          |
# |                                             |    
# | exec "$@"                                   |
# |                                             |
#  ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
#
# - Unlike the shell form the exec form doesn't invoke a command shell, this means that normal shell
# processing doesn't happen; ENTRYPOINT ["echo","$HOME"] won't do variable substitution on $HOME
#
# - if you need a variable substitution in exec form; ENTRYPOINT ["sh","-c","echo $HOME"]
#
#
# SHELL FORM ENTRYPOINT
#
# - You may specify a plain string for the ENTRYPOINT and it will execute in /bin/sh -c, this form will
# use shell processing to substitute shell environment variables and ignore and CMD or "docker run"
# command line arguments.
#
# - To ensure that docker stop will signal any long running ENTRYPOINT executable correctly, you need
# to remember to start it with "exec", it'll run on PID 1.
#
#  ________________________
# |                        |         
# | FROM ubuntu            | 
# | ENTRYPOINT exec top -b |  
# |                        | 
#  ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
#
# ENTRYPOINT & CMD Interaction:
#
# 1:
#
# ENTRYPOINT ["executable","param1"] 
#                                    \
#                                      -> executalbe param1 param2
# CMD ["executable","param2"]        /
#
# 2:
# 
# ENTRYPOINT ["executable","param1"] 
#                                    \
#                                      -> executalbe param1 /bin/sh -c param2
# CMD executable param2              /
#
# 3:
#
# ENTRYPOINT exec command param1 
#                                                        \
#                                                          -> exec command param1
# CMD executable param2  or CMD ["executable","param2"]  /



# VOLUME
#
# > VOLUME ["/data"]
#
# - The VOLUME isntruction creates a mount point with the specified name and marks it as holding
# externally mounted volumes from native host or other containers.
#
# - The value can be a JSON array "VOLUME ["/etc/log"] or a plain string with multiple arguments
# such as "VOLUME /etc/log" or "VOLUME /etc/log /etc/db"
#
# - The "docker run" command initializes the newly created volume with any data that exists at the
# specified location within the base image.
#
# Example:
# 
# FROM ubuntu
# RUN mkdir /vol
# RUN echo "Hola Amigos" > /vol/entry.txt
# VOLUME /vol
#
# - The Dockerfile builds an image that causes "docker run" to create a new mount point at /vol and
# copy entry.txt file into the "/vol/". ( --mount type=bind )
# 



# USER
#
# > USER <user>[:<group>]  or  USER <UID>[:<GID>]
#
# The USER instruction sets the user name or UID and optionally the user group or GID to use when
# running the image and for any RUN, CMD and ENTRYPOINT instructions that follow it in the Dockerfile
# 
# NOTE
# - When specifying a group for the user, the user will have only the specified group membership, any
# other configured group memberships will be ignored.
# 
# - When the user doesn't have a primary group then the image will be run with the "root" group.
#
# - On Windows, the user must be created first if it's not a built-in account, this can be done with
# the net user command called as part of a Dockerfile.
# 
# Windows:
#
# FROM microsoft/windowsservercore
# RUN net user /add john
# USER john
#
# Linux:
# 
# FROM ubuntu:latest
# ENTRYPOINT ["/bin/bash"]
# RUN mkdir /vol
# RUN echo "Hola Amigos" > /vol/entry.txt
# VOLUME /vol
# RUN useradd -G daemon,video -u 1053 -m 
# USER fox
# WORKDIR /home/fox



# WORKDIR
#
# > WORKDIR /path/dir
#
# - The WORKDIR instruction sets the working directory for any RUN, CMD, ENTRYPOINT, COPY and ADD
# instructions that follow it in the Dockerfile. If the WORKDIR doesn't exist it'll be created 
# even if it's not used in any subsequent Dockerfile instruction.
#
# - The WORKDIR instruction can be used multiple times in a Dockerfile, if a relative path is provided
# it will be relative to the path of the previous WORKDIR instruction
# 
# Example:
# 
# WORKDIR /usr
# WORKDIR logs
# WORKDIR docker.logs.d
#
# RUN pwd --> /usr/logs/docker.logs.d
#
# - The WORKDIR instruction can resolve environment variable previously set using ENV
# 
# Example:
#
# ENV DIRPATH=/path
# WORKDIR $DIRPATH/$DIRNAME
#
# RUN pwd --> /path/$DIRNAME
#
# - if not specified the default working directory is "/", in practice if you aren't building a
# Dockerfile from scratch ( FROM scratch ) the WORKDIR may likely be set by the base image you're using.



# ARG
# 
# > ARG <name>[=<default value>]
#
# - The ARG instruction defines a variable that users can pass at build-time to the builder with the
# "docker build" command using the "--build-arg <name>=<value>" flag. If a user specifies a build argument
# that was not defined in the Dockerfile, the build outputs a warning.
#
# - A Dockerfile may include one or more ARG instructions.
# 
# Example:
#
# FROM ubuntu
# ARG user1=fox  --> default is fox if "--build-arg user1" is not specified.
# ARG buildno=1  --> default is 1 
# ...
#
# WARNING
#
# - it's not recommended using build-time variables for passing secrets like github keys, user credentials
# - Build-time variables are visible to any user of the image with the "docker history" command!
#
# DOCKER BUILD SECRET information
# 
# - The new --secret flag for docker build allows the user to pass secret information to be used in
# the Dockerfile for building docker images in a safe way that won't end up stored in the final image.
# 
# - "id" is the identifier to pass into the docker build --secret, this identifier is associated with the
# RUN --mount identifier to use in the Dockerfile.
#
# - Docker doesn't use the filename of where the secret is kept outside of Dockerfile, since this may
# be sensitive information.
#
# - "dst" renames the secret file to a specific file in the Dockerfile RUN command to use.
#
# Example:
# 
# secret file location on host machine : /var/secrets/git-secret
#
# FROM alpine
#  _______________________________________________________________________________________________
# |                                                                                               |  
# | When you grant a newly-created or running service access to a secret,                         |
# | the decrypted secret is mounted into the container in an in-memory filesystem.                |
# | The location of the mount point within the container defaults to "/run/secrets/<secret_name>" |
# | in Linux containers, or C:\ProgramData\Docker\secrets in Windows containers.                  |  
# | You can also specify a custom location.                                                       |  
# |                                                                                               |  
#  ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾ 
#
# # default location in container
# RUN --mount=type=secret,id=gitkey cat /run/secrets/gitkey
# 
# # custom location in container
# RUN --mount=type=secret,id=gitkey,dst=/app/secrets/gitsecret cat /app/secrets/gitsecret
#
# - The secret needs to be passed to the build using the --secret flag.
#
# > docker build --no-cache --progress=plain --secret id=gitkey,src=/git/secrets/git-app-key.txt
# 
# - In this case secrets won't be exposed in docker history
#
# - Container will have an empty directory "/run/secrets/"
# 
# USING SSH to ACCESS PRIVATE DATA in BUILDS
#
# - Some commands in a Dockerfile may need specific SSH authentication.
#
# - For instance, to clone a private repository, rather than copying private keys into the image, which runs
# the risk of exposing them publicly, "docker build" provides a way to use the host system's ssh access while
# building the image.  
#
# There're three steps to this process:
#
# - Run "ssh-add" to add private key identities to the authentication agent. If you have more than one SSH key
# and your default "id_rsa" isn't the one you use for accessing the resources in question, you'll need to add
# that key by path: "ssh-add ~/.ssh/<keys>"
#
# - When running "docker build", use the --ssh option to pass in an existing SSH agent connection socket;
# for example, "--ssh default=$SSH_AUTH_SOCK" or the shorter equivalent "--ssh default".
#
# - To use that SSH access in a "RUN" command in the Dockerfile, define a mount with type ssh, this will set
# the "SSH_AUTH_SOCK" environment variable for that command to the value provided by the host to "docker build"
# which will cause any programs in the "RUN" command which rely on SSH to automatically use that socket.
# 
# Example:
#
# FROM alpine
#
# # Install ssh client and git
# RUN apk add --no-cache openssh-client git
#
# # Download public key for github.com
# RUN mkdir -p -m 0700 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts
#
# # Clone private repository
# RUN --mount=type=ssh git clone git@github.com:myorg/myproject.git myproject
#
# # Clone private repository with multiple SSH sockets
# RUN --mount=type=ssh,id=development git clone git@github.com:myorg/myproject.git devProject
# RUN --mount=type=ssh,id=staging git clone git@github.com:myorg/myproject.git stgProject
#
# - Image can be built by 
# - Single Socket   : "docker build --ssh default . "
# - Multiple Socket : "docker build --ssh development=$SSH_AUTH_SOCK --ssh staging=$OTHER_AUTH_SOCK ."
# 
# - If a "--mount=type=ssh" doesn't specify an "id", default is assumed
#   > docker build --mount=type=ssh 
#
# SCOPE of ARG
#
# - An ARG variable definition comes into effect from the line on which it's defined in the Dockerfile, not from
# the argument's use on the command-line or elsewhere.
# 
# > docker build --build-arg user=fox
#
# Example:
# 
# FROM busybox
# USER ${user:-sabitk}  --> USER sabitk
# ARG user
# USER $user            --> USER fox
#
#
# - To use an ARG in multiple stages, each stage must include the ARG instruction.
#
# Example:
#
# FROM busybox
# ARG DEFAULT_SETTINGS
# RUN ./run/setup $DEFAULT_SETTINGS
#
# FROM busybox
# ARG DEFAULT_SETTINGS
# RUN ./run/setup-helper $DEFAULT_SETTINGS
#
#
# ENV & ARG Interaction
#
# - Environment variables defined using the ENV instruction always override an ARG instruction of the same name
# 
# > docker build --build-arg CONT_IMG_VER=v2.0.1
#
# Example:
#
# FROM alpine
# ARG CONT_IMG_VER
# ENV CONT_IMG_VER=v1.0.0
# RUN echo $CONT_IMG_VER    --> RUN echo v1.0.0 , ENV overrides ARG
#
# Useful Interaction between ENV & ARG
#
# Example:
#
# FROM alpine
# ARG CONT_IMG_VER
# ENV CONT_IMG_VER=${CONT_IMG_VER:-v1.0.0}
#
#                        
#                       /‾‾‾ >> docker build . : RUN echo v1.0.0
# RUN echo $CONT_IMG_VER   
#                       \___ >> docker build --build-arg CONT_IMG_VER=v2.0.0 : RUN echo v2.0.0
#
#
#
# Predefined ARGs
#
# Docker has a set of predefined ARG variables that you may use without a corresponding ARG instruction in Dockerfile
# 
# - HTTP_PROXY, HTTPS_PROXY, FTP_PROXY, NO_PROXY
# - http_proxy, https_proxy, ftp_proxy, no_proxy
#
# To use these, pass them on the command line using the --build-arg flag
# 
# > docker build --build-arg HTTPS_PROXY=https://my-proxy.example.com
#
# - By default these pre-defined variables are excluded from the output of "docker history", excluding them
# reduces the risk of accidentally leaking sensitive authentication information in an HTTP_PROXY variable.
#
# - Consider building the following Dockerfile using "--build-arg HTTP_PROXY=http://user:....."
# 
# Example:
# 
# FROM ubuntu
# RUN echo "Hola Amigos"
#
# - In this case, the value of the "HTTP_PROXY" variable isn't available in the "docker history" and isn't cached
# If you were to change location, your proxy server chaned to "http://user:pass@proxy.sfo.example.com"
# a subsequent build doesn't result in a cache miss.
#
# - If you need to override this behaviour then you may do so by adding an ARG statement in the Dockerfile as follows
#
# Example:
#
# FROM ubuntu
# ARG HTTP_PROXY
# RUN echo "Hola Amigos"
#
# - When building this Dockerfile, the "HTTP_PROXY" is preserved in the "docker history" and changing its value
# invaluidates the build cache.
#
# Configure Docker to Use a Proxy Server: https://docs.docker.com/network/proxy/#configure-the-docker-client
#
# IMPACT ON BUILD CACHING
#
# - ARG variables aren't persisted into the built image as ENVs are, ARG variables do impact the build cache in
# similar ways.
#
# - If a Dockerfile defines an ARG variable whose value is different from a previous build then a "cache miss"
# occurs upon its first usage, not its definition. 
#
# - All RUN instructions following an ARG use the ARG variable implicitly ( as an environment variable )
# thus can cause a cache miss.
#
# - All predefined ARG variables are exempt from caching unless there is a matching ARG statement in Dockerfile.


# STOPSIGNAL
#
# > STOPSIGNAL signal
#
# The instruction sets the system all signal that will be sent to container to exit
# 
# Example:
# 
# FROM ubuntu
# ENTRYPOINT ["/bin/bash"]
# STOPSIGNAL SIGTERM  : SIG<term> , Check Linux Termination Signals
#
# - it can be overridden per container by "docker run/create --stop-signal"



# HEALTHCHECK
#
# It has two forms:
# 
# - HEALTHCHECK [OPTIONS] CMD command (check container health by running a command inside the container)
# - HEALTHCHECK NONE (disable any healthcheck inherited from the base image)
#
# - The instruction tells Docker how to test a container to check taht it's still working, this can detect
# cases such as a web server that is stuck in an infinite loop and unable to handle new connections, though
# server process is still running.
#
# - When a container has a healthcheck specified, it has a health status in addition to its normal status,
# this status is initially "starting", whenever a health check passes it becomes "healthy", after a certain 
# number of consecutive failures it becomes "unhealthy"
#
# OPTIONS:
# 
# --internal=DURATION     (30s by default)
# --timeout=DURATION      (30s by default)
# --start-period=DURATION (0s by default)
# --retries=N             (3 by default)
#
# - The HEALTHCHECK first runs "interval" seconds after the container starts & --start-period time, then again
# "interval" seconds after each previous check completes.
#
# - If a single run of the check takes long than "timeout" seconds then the check is considered to have failed.
# 
# - It takes "retries" consecutive failures of the health check for the container to be considered "unhealthy"
#
# - "start-period" provides initialization time for containers that need time to bootstrap, probe failure during
# that period won't be counted towards the maximum number of retries, however, if a health check succeeds during
# the start period, the container is considered started and all consecutive failures will be counted towards the
# maximum number of retries.
#
# - There can only be one HEALTHCHECK instruction in Dockerfile, if you list more than one then only the last
# HEALTHCHECK will take effect.
#
# - The command after the CMD can be either a shell command or an exec array.
#
# Possible exit status:
# 
# 0 : success  ,  container is healthy and ready for use
# 1 : unhealthy,  container is not working correctly
# 2 : reserved ,  don't use this exit code!
#
# Example:
# 
# - Check every five mins that a web-server is able to serve the site's main page within three secs.
#
# > HEALTHCHECK --interval=5m --timeout=3s \
# CMD curl -f http://localhost/ || exit 1
#
# - When the health status of a container changes, a "health_status" event is generated with the new status. 

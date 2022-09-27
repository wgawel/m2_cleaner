# [M2 Cleaner](https://github.com/wgawel/m2_cleaner)
A script to automatically remove unnecessary Maven artifacts in the .m2 folder.

`M2 Cleaner` is script to automatically remove unnecessary artifacts in the .m2 folder.

How it's working?

0. Configure the script (project name and optional list of unnecessary artifacts).
1. Run the script *m2_cleaner.sh*.
2. Enter the path to .m2 (or confirm the default).
3. Enter the version of the project from which the artifacts should not be removed (in the format "x.x.x.x", eg "3.9.9.0" or shorter "3.9.9").
4. Enter information whether you want to remove all artifacts from the additional list defined in point 0.
5. Done! 

# Notes

> Script written to run on Cmder (or other bash command line) in Windows. 

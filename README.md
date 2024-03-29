# FunParTools

## Table of Contents

* [Description](#description)
* [Installation](#installation)
* [Usage](#usage)
* [Issues](#issues)
* [Contact Information](#contact-information)
* [License Information](#license-information)

## Description

The *FunParTools* *Matlab* toolbox is part of the *TensCalc* *Matlab*
toolbox but is useful on its own right. It provides functions to

1. declare *named* inputs to a *Matlab* function in the form:

	```matlab
	f('variable 1',value1,'variable 2',value2, ...)
	```

2. set *default* values for inputs not provided (optional)

3. test if the input values fall within *admissible* sets (optional)

4. automatically generate *documentation* from declared inputs

5. automatically saving output/input values to files with an
   accompanying *pedigree* file that described the parameters used to
   generate the outputs (optional)

6. bypass function execution if the function has been previously
   called with the same parameters and the outputs were saved
   (optional)

This toolbox is mostly useful when 

1. writing functions with many input arguments to simplify calling the
   function with *default* inputs
   
	and/or

2. writing scripts that do *batch processing* of large data sets with
   multiple steps (each affected by parameters) to minimize calling
   functions whose inputs have not changed

## Installation

1. Download *FunParTools* using one of the following options

	1. downloading it as a zip file from
		https://github.com/hespanha/funpartools/archive/master.zip
 	   and unziping to an appropriate location

	2. cloning this repository with svn, e.g., using the shell command
	   ```sh
	   svn checkout https://github.com/hespanha/funpartools.git
	   ```
	  
	3. checking out this repository with Git, e.g., using the shell command
	   ```sh
       git clone https://github.com/hespanha/funpartools.git
       ```

	The latter two options are recommended because you can
    subsequently use `svn update` or `git pull` to upgrade
    *FunParTools* to the latest version. Under Windows 10, we use the
    following git client: https://git-scm.com/download/win

	After this, you should have at least the following folders:

	* `funpartools`
	* `funpartools/lib`
    * `funpartools/examples`

2. Enter `funpartools` and execute the following command at the *Matlab* prompt:

	```matlab
	install_funpartools
	```

3. To test if all is well, go to `funpartools/examples` and execute

	```matlab
	createMatrix help
	testFlow
	```

## Usage

*Matlab* functions that use *FunParTools* take the following general form:

```matlab
function [varargout]=functionName(varargin)
% For help on the input parameters type 'functionName Help'
    
  % Function global help
  declareParameter(...
    'Help', { '...' })
    
  % Declare all input parameters, see 'help declareParameter'
  declareParameter( .... );
    
  % Declare all output parameters, see 'help declareOutput'
  declareOutput( .... );
    
  % Retrieve parameters and inputs
  [stopNow,params]=setParameters(nargout,varargin);
  if stopNow
    return;
  end
    
  % Start main code here
    
  ....
    
  % Set outputs
  vargout=setOutputs(nargout,params);
    
end
```

This function is then called using the syntax:

``` matlab
[output1,output2,...]=functionName('input1',value1,'input2',value2,...);
```

The function's documentation can be obtained using the following syntax:

``` matlab
functionName help
```

The function's latex-formated documentation can be obtained using the
following syntax. This also produces a file with the latex-formated
documentation with the same name as the function, but with the
extension .tex (instead of .m).

``` matlab
createGateway help latex
```

*FunParTools* contains its own documentation embedded into the *Matlab*
scripts. To see it, type at the *Matlab* prompt:

``` matlab
help setParameters
help declareParameter
help declareOutput
```

## Issues

This toolbox has been in use for a while so it should have a
relatively small number of bugs.

At this time, the biggest issue is probably the use of fairly obscure
error messages when things go wrong.

## Contact Information

Joao Hespanha (hespanha@ece.ucsb.edu)

http://www.ece.ucsb.edu/~hespanha

University of California, Santa Barbara
	
## License Information

This file is part of Tencalc.

Copyright (C) 2010-21 The Regents of the University of California
(author: Dr. Joao Hespanha).  All rights reserved.

See LICENSE.txt

# Instructions for setting up FamiliarFaces Repo:


## Before setting up:
* Install git, using any of the following:
  * [Git for Windows](https://git-for-windows.github.io/) (has a bunch of extra stuff, like a GUI and full BASH shell)
  * [GitHub Desktop](https://desktop.github.com/) (has even more extra stuff, with better github integration)
  * [Tortoise Git](https://tortoisegit.org/) (Simple gui+git, nothing else, works as well as GitHub Desktop, but simpler)
  * sudo apt install git (Linux)
* Open a terminal and run git. If it isn't found, add it to your PATH
  * [Instructions](https://www.kb.wisc.edu/cae/page.php?id=24500)
* Install [Love2D](https://love2d.org/).

---
## Sublime Text 2/3:
  * Install Package Control if it's not already installed. (ctrl+shift+p, type package, if it shows up, you're good!)
	
  * Install the following packages:
     * SublimeLove (Love2D integration and build system)
     * GitSavvy (Git integration)
     * Floobits (Real-time collaboration)
	
  * Optional Packages I recommend, but you don't need: 
     * Restart (f5 to restart Sublime)
     * FormatLua (adds alt+l shortcut to format Lua code)
     * LuaSmartTips (adds auto-complete information for Lua code)
     * SidebarEnhancements (adds more options to the right click menu of files/folders in the sidebar)
     * BracketHighlighter (Highlights the brackets for the current scope)
      * If you use the SublimeLove language, you need to add it. It's in the bracket settings, just add "Love" to the Lua language.
     * ColorCoder (Colors EVERY function and variable in the editor differently. Some people HATE this.)
     * GitGutter (Shows the diffs between your build and the one on github)
     * SublimeLinter + SublimeLinter-luacheck (Error checking. You need to install LuaCheck for this, though)
     * RegExLink (Opens links in your browser by right clicking)


	
  * Go to tools->build system, and switch it to Love.
	  * Press ctrl+shift+p, run git: clone, enter https://github.com/moomoomoo309/FamiliarFaces as the URL.
	
  * Use [these instructions](https://help.github.com/articles/creating-an-access-token-for-command-line-use/) to generate an access token for your GitHub account.
	
  * Open a terminal, and cd into the directory of the repository.
     * If you don't know how to do this...you really should.
     * cd stands for "change directory", and will go from your current directory (to the left of your cursor) into the directory you specify.
     * For example, if you are in a folder called "home", and you want to access a subfolder called "sub", you run cd sub.
     * If you want to go to the parent folder, use .. to refer to the parent directory.
	
  * Run git config remote.origin.url "https://{token}@github.com/moomoomoo309/FamiliarFaces.git"
     * Replace {token} with the token you generated on the GitHub site.
	
  * To make sure it works, hit ctrl+shift+p and run git: commit, and follow the instructions there.
     * Make the commit message something like "sublime text test commit"
     * Finally, hit ctrl+shift+p again, and run git: push.
     * Go to [the repo](https://github.com/moomoomoo309/FamiliarFaces) and you should see your commit.  

---
## IntelliJ-based IDEs (PyCharm, IntelliJ, etc.):
  * Go to help->find action, and go to Plugins...
  * Click on "Browse additional repositories"
  * Search for and install the following:
    * Floobits
    * Lua
    * Hyperlinks (Optional, but useful)
  * Install the [love-IDEA-plugin](https://github.com/rm-code/love-IDEA-plugin) using the instructions on the page.
  * Go to New->Project from Version Control->GitHub, and use the following URL.
     * https://github.com/moomoomoo309/FamiliarFaces
  * To set up the build system:
     * Go to file->settings, and search for external tools.
     * Add a new tool, and set the following:
       * Program: path to love.exe (Don't type that directly, put the actual path!)
       * Parameters: $SourcePath$
       * Add a shortcut to it (I used Ctrl + B)
     
  
Notes on IntelliJ for Love2D Development:
* The auto completion for Love2D doesn't work once you put a period. If you want love.math.something, type "loma" and it'll pop the suggestions up. 
		

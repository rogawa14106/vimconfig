# SETUP
1. install nvim  
    there are meny ways to install nvim.  
    please install nvim in a way that suits your environment.  

2. install required applications  
    See ['Note > dependencies'](#note_dependencies) for required applications  

3. clone nvim settings (it is this repository)  
    ```
    mkdir -p ~/.config/nvim/
    git clone https://github.com/rogawa14106/vimconfig ~/.config/nvim/.
    ```

4. launch nvim  
    ```
    nvim
    ```

# NOTE
<div id="note_dependencies"></div>

* dependencies  
    - curl  
        curl is required to use 'util/translator'  
    - npm  
        npm is required to install some LSPs  
    - nardfont  
        nardfont is required to display some icons when you use 'lazy.nvim'. and more.  
    - mdr  
        mdr is required to use 'preview-markdown.nvim'  
    - wl-clipboard  
        wal-clipboard is required to use the system clipboard with Nvim if you are using wayland as your display system.  
        h: clipboard  

* about /bin  
    if you use the following command to change the IME, these commands shuoud be in your path. (windows only)  
    `chime` `hidesb`  


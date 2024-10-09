# SETUP
1. Install nvim  
    Install nvim in a way that suits your environment.  

2. Install required applications  
    See ['Note > dependencies'](#note_dependencies) for required applications  

3. Clone nvim settings (it is this repository)  
    ```
    mkdir -p ~/.config/nvim/
    git clone https://github.com/rogawa14106/vimconfig ~/.config/nvim/.
    ```

4. Launch nvim  
    ```
    nvim
    ```

# NOTE
<div id="note_dependencies"></div>

* Dependencies  
    - curl  
        curl is required to use 'util/translator'  
    - npm  
        npm is required to install some LSPs  
    - nardfont  
        nardfont is required to display some icons when you use 'lazy.nvim'. and more.  
    - mdr  
        mdr is required to use 'preview-markdown.nvim'  
    - wl-clipboard  
        wl-clipboard is required to use the system clipboard with Nvim if you are using wayland as your display system.  
        See h: clipboard  

* About /bin  
    if you use the following command to change the IME, /bin shuoud be in %PATH%. (windows only)  
    `chime` `hidesb`  


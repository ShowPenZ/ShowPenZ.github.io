#!/bin/sh
# ================================================================== #
# Shell script to autoinstall Hexo & NexT & NexT website source.
# ================================================================== #
echo
echo "=============================================================="
echo " Installing Hexo & NPM modules..."
echo "=============================================================="
    npm install

echo
echo "=============================================================="
echo " Cloning NexT theme & Adding needed modules..."
echo "=============================================================="
    git clone https://github.com/theme-next/hexo-theme-next themes/next --depth=1

echo
echo "=============================================================="
echo " Checking Hexo version..."
echo "=============================================================="
    hexo -v
    cat package.json

echo
echo "=============================================================="
echo " Strarting Hexo server on \"http://localhost:4000\"..."
echo "=============================================================="
    hexo s

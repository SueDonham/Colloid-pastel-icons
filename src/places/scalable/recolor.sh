 
#!/bin/bash

color_folders() {
  case "$color" in
    '') theme_color='#c3b6c9' ;;
    -blue) theme_color='#b9cfde' ;;
    -pink) theme_color='#f4b9be' ;;
    -red) theme_color='#d19494' ;;
    -orange) theme_color='#f5cba3' ;;
    -yellow) theme_color='#f3dea4' ;;
    -green) theme_color='#aac69f' ;;
    -teal) theme_color='#9fc6be' ;;
    -grey) theme_color='#a19d91' ;;
  esac
}



sed -i "s/#ff0000/#c3b6c9/g" *.svg
# sed -i "s/#a19d91/#c3b6c9/g" *.svg

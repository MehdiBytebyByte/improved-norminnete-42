for file in *; do
    if [[ ! $file =~ \.c$ && ! $file =~ \.h$ && $file != "Makefile" ]]; then
        read -p "Do you want to delete '$file'? (y/n): " response
        case "$response" in
            [yY]) 
                rm -rf "$file"
                echo "'$file' has been deleted."
                ;;
            [nN]) 
                echo "'$file' was not deleted."
                ;;
            *) 
                echo "Invalid response. Skipping '$file'."
                ;;
        esac
    fi
done
echo "Cleanup process completed."

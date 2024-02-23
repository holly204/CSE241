# Prompt user for input
echo "Enter the text you want to display with figlet:"
read input_text

# Display the output using figlet
echo input_text | faas-cli invoke figlet

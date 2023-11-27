#!/bin/bash

# Check if the user has root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root"
  exit 1
fi

# Check if the user has provided an interface name
if [ -z "$1" ]; then
  echo "Please provide an interface name as an argument"
  exit 2
fi

# Check if the interface exists
if ! ip link show "$1" &> /dev/null; then
  echo "The interface $1 does not exist"
  exit 3
fi

# Check if macchanger is installed
if ! command -v macchanger &> /dev/null; then
  echo "macchanger is not installed. Please install it using your package manager"
  exit 4
fi

# Store the original MAC address
orig_mac=$(ip link show "$1" | awk '/ether/ {print $2}')

# Turn off the interface
ip link set dev "$1" down

# Change the MAC address to a random one
macchanger -r "$1" &> /dev/null

# Turn on the interface
ip link set dev "$1" up

# Store the new MAC address
new_mac=$(ip link show "$1" | awk '/ether/ {print $2}')

# Print the results
echo "The MAC address of $1 has been changed from $orig_mac to $new_mac"

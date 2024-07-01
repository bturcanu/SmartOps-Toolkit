#!/bin/bash

# System Health Check Script
# Author: Bogdan Turcanu
# Date: 6/30/2024
# Description: This script performs a comprehensive system health check, including CPU usage, memory usage, disk usage, network latency, and running services status.

# Function to check CPU usage
check_cpu() {
    echo "=============================="
    echo "CPU Usage:"
    echo "------------------------------"
    mpstat | awk '$12 ~ /[0-9.]+/ { print "CPU Idle: " 100 - $12"%"}'
    top -bn1 | grep "Cpu(s)" | awk '{print "CPU Load: " $2 + $4 "%"}'
    echo "=============================="
}

# Function to check Memory usage
check_memory() {
    echo "=============================="
    echo "Memory Usage:"
    echo "------------------------------"
    free -m | awk 'NR==2{printf "Memory Usage: %.2f%% (Used: %sMB, Free: %sMB)\n", $3*100/$2, $3, $4}'
    echo "=============================="
}

# Function to check Disk usage
check_disk() {
    echo "=============================="
    echo "Disk Usage:"
    echo "------------------------------"
    df -h | awk '$NF=="/"{printf "Disk Usage: %s (%s/%s)\n", $5, $3, $2}'
    echo "=============================="
}

# Function to check Network Latency
check_network() {
    echo "=============================="
    echo "Network Latency:"
    echo "------------------------------"
    ping -c 4 google.com | tail -2 | head -1
    echo "=============================="
}

# Function to check running services
check_services() {
    echo "=============================="
    echo "Running Services:"
    echo "------------------------------"
    systemctl list-units --type=service --state=running | grep '.service'
    echo "=============================="
}

# Function to display system information
system_info() {
    echo "=============================="
    echo "System Information:"
    echo "------------------------------"
    hostnamectl
    echo "=============================="
}

# Main function to run all checks
main() {
    echo "==========================================="
    echo "         Comprehensive System Health Check"
    echo "==========================================="
    system_info
    check_cpu
    check_memory
    check_disk
    check_network
    check_services
    echo "==========================================="
    echo "System health check completed successfully!"
    echo "==========================================="
}

# Run the main function
main

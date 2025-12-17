# Kill process(es) running on a specific port or port range
function killport
    if test (count $argv) -eq 0
        echo "Usage: killport <port_number|port_range>"
        echo "Examples:"
        echo "  killport 3000        # Kill process on port 3000"
        echo "  killport 3000-3015   # Kill processes on ports 3000 through 3015"
        return 1
    end

    set -l input $argv[1]
    set -l ports
    set -l killed_pids
    set -l total_killed 0

    # Check if input contains a range (has a dash)
    if string match -qr '-' "$input"
        # Parse range
        set -l start_port (string split - '-' "$input" | head -n 1)
        set -l end_port (string split - '-' "$input" | tail -n 1)

        # Validate range
        if not string match -qr '^\d+$' "$start_port"; or not string match -qr '^\d+$' "$end_port"
            echo "❌ Invalid port range format. Use: start_port-end_port (e.g., 3000-3015)"
            return 1
        end

        if test $start_port -gt $end_port
            echo "❌ Start port must be less than or equal to end port"
            return 1
        end

        echo "🔍 Scanning ports $start_port-$end_port for running processes..."

        # Generate port range
        for port in (seq $start_port $end_port)
            set ports $ports $port
        end
    else
        # Single port
        if not string match -qr '^\d+$' "$input"
            echo "❌ Invalid port number: $input"
            return 1
        end
        set ports $input
    end

    # Process each port
    for port in $ports
        set -l pids (lsof -ti :$port 2>/dev/null)

        if test -n "$pids"
            echo ""
            echo "=== Port $port ==="
            lsof -i :$port 2>/dev/null

            echo "Killing processes on port $port: $pids"
            kill -9 $pids 2>/dev/null

            # Track killed PIDs (avoid duplicates)
            for pid in $pids
                if not contains $pid $killed_pids
                    set -a killed_pids $pid
                end
            end

            set total_killed (math $total_killed + (count $pids))
        end
    end

    if test $total_killed -eq 0
        if test (count $ports) -eq 1
            echo "No processes found running on port $ports[1]"
        else
            echo "No processes found running on ports $start_port-$end_port"
        end
        return 0
    end

    # Verify processes were killed
    sleep 1
    echo ""
    echo "📊 Summary:"
    echo "Total processes killed: $total_killed"
    echo "Unique PIDs killed: $killed_pids"

    # Check for any remaining processes
    set -l remaining_count 0
    for port in $ports
        set -l remaining (lsof -ti :$port 2>/dev/null)
        if test -n "$remaining"
            set remaining_count (math $remaining_count + 1)
        end
    end

    if test $remaining_count -eq 0
        echo "✅ All processes successfully killed"
    else
        echo "⚠️  $remaining_count port(s) may still have running processes"
    end
end


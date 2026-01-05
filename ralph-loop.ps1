# Ralph Loop for Windows - Autonomous Claude Code Loop
# Based on the Ralph Wiggum technique by Geoffrey Huntley
# This script creates an autonomous development loop using Claude Code

param(
    [Parameter(Mandatory=$true)]
    [string]$Prompt,

    [Parameter(Mandatory=$false)]
    [int]$MaxIterations = 50,

    [Parameter(Mandatory=$false)]
    [string]$CompletionPromise = "COMPLETE",

    [Parameter(Mandatory=$false)]
    [string]$PromptFile = "",

    [Parameter(Mandatory=$false)]
    [switch]$Verbose
)

# Configuration
$Script:IterationCount = 0
$Script:StartTime = Get-Date
$Script:LogFile = "ralph-log-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').txt"

# Colors for output
function Write-Info { Write-Host "[INFO] $args" -ForegroundColor Cyan }
function Write-Success { Write-Host "[SUCCESS] $args" -ForegroundColor Green }
function Write-Warning { Write-Host "[WARN] $args" -ForegroundColor Yellow }
function Write-Error { Write-Host "[ERROR] $args" -ForegroundColor Red }
function Write-Iteration { Write-Host "[ITERATION $Script:IterationCount] $args" -ForegroundColor Magenta }

# Log function
function Log-Message {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Add-Content -Path $Script:LogFile
    if ($Verbose) {
        Write-Host $Message -ForegroundColor Gray
    }
}

# Display banner
function Show-Banner {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "    RALPH LOOP - Windows Edition" -ForegroundColor Yellow
    Write-Host "    Autonomous Claude Code Loop" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Info "Max Iterations: $MaxIterations"
    Write-Info "Completion Promise: $CompletionPromise"
    Write-Info "Log File: $Script:LogFile"
    Write-Host ""
}

# Check for completion promise in output
function Check-Completion {
    param([string]$Output)

    if ($Output -match [regex]::Escape($CompletionPromise)) {
        return $true
    }

    # Also check for common completion patterns
    $completionPatterns = @(
        "<promise>$CompletionPromise</promise>",
        "TASK COMPLETE",
        "ALL TASKS COMPLETED",
        "MISSION ACCOMPLISHED"
    )

    foreach ($pattern in $completionPatterns) {
        if ($Output -match [regex]::Escape($pattern)) {
            return $true
        }
    }

    return $false
}

# Build the full prompt with iteration context
function Build-FullPrompt {
    param([string]$BasePrompt)

    $iterationContext = @"

---
ITERATION CONTEXT:
- Current iteration: $Script:IterationCount of $MaxIterations
- Time elapsed: $((Get-Date) - $Script:StartTime)
- Working directory: $(Get-Location)

IMPORTANT INSTRUCTIONS:
1. Review your previous work in the codebase
2. Continue from where you left off
3. Check test results and fix any failures
4. When ALL requirements are met, output: <promise>$CompletionPromise</promise>
5. Do NOT output the completion promise until everything is truly done

ORIGINAL TASK:
$BasePrompt
"@

    return $iterationContext
}

# Run single Claude Code iteration
function Run-ClaudeIteration {
    param([string]$FullPrompt)

    $Script:IterationCount++
    Write-Iteration "Starting..."
    Log-Message "Iteration $Script:IterationCount started"

    # Create temp file for prompt (handles multiline better)
    $tempPromptFile = [System.IO.Path]::GetTempFileName()
    $FullPrompt | Out-File -FilePath $tempPromptFile -Encoding UTF8

    try {
        # Run Claude Code with the prompt
        # Using --print flag for non-interactive mode
        $output = ""

        Write-Info "Invoking Claude Code..."

        # Run claude with the prompt
        $output = & claude --dangerously-skip-permissions -p "$FullPrompt" 2>&1 | Out-String

        # Log output
        Log-Message "Output length: $($output.Length) characters"

        # Save iteration output
        $iterationLogFile = "iteration-$Script:IterationCount.log"
        $output | Out-File -FilePath $iterationLogFile -Encoding UTF8

        return $output
    }
    catch {
        Write-Error "Claude Code execution failed: $_"
        Log-Message "ERROR: $_"
        return ""
    }
    finally {
        # Cleanup temp file
        if (Test-Path $tempPromptFile) {
            Remove-Item $tempPromptFile -Force
        }
    }
}

# Display status
function Show-Status {
    $elapsed = (Get-Date) - $Script:StartTime
    Write-Host ""
    Write-Host "--- Status ---" -ForegroundColor Cyan
    Write-Host "Iterations: $Script:IterationCount / $MaxIterations"
    Write-Host "Elapsed: $($elapsed.ToString('hh\:mm\:ss'))"
    Write-Host "Working Dir: $(Get-Location)"
    Write-Host "--------------" -ForegroundColor Cyan
    Write-Host ""
}

# Main loop
function Start-RalphLoop {
    Show-Banner

    # Get base prompt from file or parameter
    $basePrompt = $Prompt
    if ($PromptFile -and (Test-Path $PromptFile)) {
        $basePrompt = Get-Content -Path $PromptFile -Raw
        Write-Info "Loaded prompt from file: $PromptFile"
    }

    Log-Message "Ralph Loop started with prompt: $($basePrompt.Substring(0, [Math]::Min(100, $basePrompt.Length)))..."

    while ($Script:IterationCount -lt $MaxIterations) {
        Show-Status

        # Build full prompt with iteration context
        $fullPrompt = Build-FullPrompt -BasePrompt $basePrompt

        # Run iteration
        $output = Run-ClaudeIteration -FullPrompt $fullPrompt

        # Check for completion
        if (Check-Completion -Output $output) {
            Write-Success "Completion promise detected!"
            Write-Success "Task completed after $Script:IterationCount iterations"
            Log-Message "COMPLETED after $Script:IterationCount iterations"

            # Final summary
            Write-Host ""
            Write-Host "========================================" -ForegroundColor Green
            Write-Host "    TASK COMPLETED SUCCESSFULLY!" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Green
            Write-Host "Total iterations: $Script:IterationCount"
            Write-Host "Total time: $((Get-Date) - $Script:StartTime)"
            Write-Host "Log file: $Script:LogFile"

            return
        }

        Write-Info "No completion promise detected. Continuing to next iteration..."
        Log-Message "Iteration $Script:IterationCount completed, no completion promise found"

        # Small delay between iterations to prevent rate limiting
        Start-Sleep -Seconds 2
    }

    # Max iterations reached
    Write-Warning "Maximum iterations ($MaxIterations) reached without completion"
    Log-Message "Max iterations reached without completion"

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "    MAX ITERATIONS REACHED" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "The task did not complete within $MaxIterations iterations."
    Write-Host "Check the logs and iteration files for progress."
}

# Handle Ctrl+C gracefully
$null = Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action {
    Write-Host ""
    Write-Warning "Ralph Loop interrupted by user"
    Log-Message "Loop interrupted by user at iteration $Script:IterationCount"
}

# Trap Ctrl+C
trap {
    Write-Host ""
    Write-Warning "Ralph Loop interrupted!"
    Write-Host "Iterations completed: $Script:IterationCount"
    Write-Host "Log file: $Script:LogFile"
    break
}

# Run the loop
Start-RalphLoop

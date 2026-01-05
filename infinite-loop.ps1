# Infinite Claude Code Loop for Windows
# Simple interactive version - continues iterating until you stop it
# Each iteration builds on the previous work

param(
    [Parameter(Mandatory=$false)]
    [string]$PromptFile = "PROMPT.md",

    [Parameter(Mandatory=$false)]
    [int]$MaxIterations = 0,  # 0 = infinite

    [Parameter(Mandatory=$false)]
    [int]$DelaySeconds = 5
)

$Script:Iteration = 0
$Script:StartTime = Get-Date

function Write-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "  ===============================================" -ForegroundColor Cyan
    Write-Host "       INFINITE CLAUDE CODE LOOP" -ForegroundColor Cyan
    Write-Host "       Press Ctrl+C to stop" -ForegroundColor Cyan
    Write-Host "  ===============================================" -ForegroundColor Cyan
    Write-Host ""
}

function Get-Prompt {
    if (Test-Path $PromptFile) {
        return Get-Content -Path $PromptFile -Raw
    }
    else {
        Write-Host "No $PromptFile found. Enter your prompt:" -ForegroundColor Yellow
        return Read-Host "Prompt"
    }
}

function Build-IterationPrompt {
    param([string]$BasePrompt)

    $elapsed = (Get-Date) - $Script:StartTime

    return @"
=== ITERATION $Script:Iteration ===
Time elapsed: $($elapsed.ToString('hh\:mm\:ss'))
Working directory: $(Get-Location)

INSTRUCTIONS:
1. Check your previous work (git log, read files)
2. Continue from where you left off
3. Run tests and fix any failures
4. Make incremental progress

TASK:
$BasePrompt

---
When completely done with ALL tasks, say: TASK COMPLETE
"@
}

function Run-Iteration {
    param([string]$Prompt)

    $Script:Iteration++

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host "  ITERATION $Script:Iteration" -ForegroundColor Magenta
    Write-Host "  $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Gray
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host ""

    # Run Claude Code
    Write-Host "Running Claude Code..." -ForegroundColor Yellow

    try {
        # Use claude command - it will run interactively
        $fullPrompt = Build-IterationPrompt -BasePrompt $Prompt

        # Save prompt to temp file
        $tempFile = "iteration-$Script:Iteration-prompt.txt"
        $fullPrompt | Out-File -FilePath $tempFile -Encoding UTF8

        # Run claude with the prompt (using --print for non-interactive)
        $output = & claude --print $fullPrompt 2>&1 | Out-String

        # Save output
        $outputFile = "iteration-$Script:Iteration-output.txt"
        $output | Out-File -FilePath $outputFile -Encoding UTF8

        Write-Host ""
        Write-Host "Iteration $Script:Iteration complete." -ForegroundColor Green
        Write-Host "Output saved to: $outputFile" -ForegroundColor Gray

        # Check for completion
        if ($output -match "TASK COMPLETE" -or $output -match "<promise>COMPLETE</promise>") {
            Write-Host ""
            Write-Host "========================================" -ForegroundColor Green
            Write-Host "  TASK COMPLETED!" -ForegroundColor Green
            Write-Host "  Total iterations: $Script:Iteration" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Green
            return $true
        }

        return $false
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor Red
        return $false
    }
}

# Main loop
Write-Banner

$basePrompt = Get-Prompt
Write-Host "Prompt loaded. Starting loop..." -ForegroundColor Green
Write-Host "Press Ctrl+C at any time to stop." -ForegroundColor Yellow
Write-Host ""

$completed = $false

while (-not $completed) {
    # Check max iterations
    if ($MaxIterations -gt 0 -and $Script:Iteration -ge $MaxIterations) {
        Write-Host ""
        Write-Host "Max iterations ($MaxIterations) reached." -ForegroundColor Yellow
        break
    }

    # Run iteration
    $completed = Run-Iteration -Prompt $basePrompt

    if (-not $completed) {
        Write-Host ""
        Write-Host "Waiting $DelaySeconds seconds before next iteration..." -ForegroundColor Gray
        Write-Host "(Press Ctrl+C to stop)" -ForegroundColor Gray

        for ($i = $DelaySeconds; $i -gt 0; $i--) {
            Write-Host "`r$i... " -NoNewline
            Start-Sleep -Seconds 1
        }
        Write-Host ""
    }
}

Write-Host ""
Write-Host "Loop ended. Total iterations: $Script:Iteration" -ForegroundColor Cyan
$elapsed = (Get-Date) - $Script:StartTime
Write-Host "Total time: $($elapsed.ToString('hh\:mm\:ss'))" -ForegroundColor Cyan

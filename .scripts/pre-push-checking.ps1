#region Helper functions

Function ExecuteApplyCodeStyle {
    #NOTE: if you wanna change checking solution on your - you should replace 'WebApi.sln' argument on your solution name.
    Invoke-Expression -Command 'dotnet jb cleanupcode --profile="TAP Cleanup" WebApi.sln';
}

Function GetGitStatus {
    $gitStatus = Invoke-Expression -Command "git status --porcelain";
    $haveUntrackedChanges = $gitStatus | Where-Object {$_ -match '^\?\?'};
    $haveUncommitedChanges = $gitStatus | Where-Object {$_ -notmatch '^\?\?'};

    if ($haveUntrackedChanges) {
        return 'haveUntrackedChanges';
    }
    if ($haveUncommitedChanges) {
        return 'haveUncommitedChanges';
    }

    return 'nothing';
}

Function CheckGitChanges {
    $gotGitChangesType = GetGitStatus;
    if ($gotGitChangesType -eq 'haveUntrackedChanges')
    {
        Write-Error "Есть не отслеживаемые изменения.`
            Существующие варианты решения:`
            - затрекать и закоммитить изменения;`
            - поместить изменения в stash;`
            - убрать изменения.";
        return 1;
    }
    if ($gotGitChangesType -eq 'haveUncommitedChanges') 
    {
        Write-Error "Есть не закоммиченные изменения.`
            Существующие варианты решения:`
            - закоммитить изменения;`
            - поместить изменения в stash;`
            - убрать изменения.";
        return 1;
    }
    return 0;
}

Function CommitAppliedCodeStyle {
    $gotGitChangesType = GetGitStatus;
    $haveChanges = $gotGitChangesType -ne 'nothing';
    if ($haveChanges)
    {
        Invoke-Expression "git commit -am ""[Autocommit] Resharper formatted files""";
        Write-Output "Done format files autocommit.`n";
    }
} 
#endregion


if (CheckGitChanges) {
    exit 1;
}
ExecuteApplyCodeStyle;
CommitAppliedCodeStyle;

#!/usr/bin/perl -w


my %set;
my %alias;

storeProfile();
setPrompt();
openHistory();

print $prompt;
$line = <STDIN>;
chomp($line);

while ($line ne "exit")
{
    @commandSplit = split(" ", $line);
    if(exists $alias{$line}){
        $command = $alias{$line};
        executeLinuxCommand($command);
    }elsif($line eq "set"){
        setCommand();
    }elsif($line eq "alias"){
        aliasCommand();
    }elsif($line eq "history"){
        showHistory();
    }elsif($commandSplit[0] eq "cd"){
            if(exists ($commandSplit[1])){
                $newDirect = $commandSplit[1];
            }else{
                $newDirect = $home;
            }
            chdir($newDirect);

    }else{
        executeLinuxCommand($line);
    }
    print HISTORY "$line\n";
    
    print($prompt);
    $line = <STDIN>;
    chomp($line);
}
close(HISTORY);

sub executeLinuxCommand 
{
    my $commandLine = shift(@_);
    my $pid = fork();
    if ($pid < 0) 
       {
        print "Unable to create child process.\n";
        exit 0; 
       }
    elsif ($pid > 0) 
    {
        wait(); 
    }
    else 
    {
        exec($commandLine);
        exit 0;
    }
}

sub openHistory{
    chdir($home);
    open(HISTORY, ">>.hush_history");
}

sub storeProfile{
    $home = $ENV{"HOME"};
    
    chdir($home);
    if(open(PROFILE, ".hush_profile")){
        
        foreach $profileLine(<PROFILE>){
            chomp($profileLine);
            @equalSplit = split("=", $profileLine);
            @leftSplit = split(" ", $equalSplit[0]);
            @rightSplit = split(" ", $equalSplit[1]);
            
            $newKey = $leftSplit[1];
            
            if($leftSplit[0] eq "set"){
                $setValue = "";
                for($i =0; $i <@rightSplit; $i++){
                    $setValue = $setValue . $rightSplit[$i]. " ";
                }
                chop($setValue);
                $set{$newKey} = $setValue;
            }elsif($leftSplit[0] eq "alias"){
                $newValue ="";
                for($i =0; $i <@rightSplit; $i++){
                    $newValue = $newValue . $rightSplit[$i] . " ";
                }
                chop($newValue);
            $alias{$newKey} = $newValue;
            }
        }
    }
    close(PROFILE);
}

sub setPrompt{
    $mainPID = $$;
    
    if(exists $set{"PROMPT"}){
        $prompt = "[hush:".$set{'PROMPT'}."]\$ ";
    }else{
        $prompt = "[hush:$mainPID]\$ "
    }
}
sub showHistory{
    print "made it to show history\n";
    chdir($home);
    open(SHOW, ".hush_history");
    $count = 1;
    foreach $histLine (<SHOW>)
    {
        chomp($histLine);
        print "$count  $histLine\n";
        $count++;
    }
    close(SHOW);
}

sub setCommand{
    foreach $setKey (sort(keys(%set)))
    {
        print "set: $setKey = $set{$setKey}\n";
    }
}

sub aliasCommand{
    foreach $aliasKey (sort(keys(%alias))){
        print "alias: $aliasKey = $alias{$aliasKey}\n";
    }
}
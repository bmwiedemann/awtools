sub spend1()
{ 
  foreach my $p (@planet) {
    while(build($p,"rf",0)){}
    while(build($p,"hf",6)){}
    while(build($p,"gc",11)){}
    while(build($p,"rl",12)){}
  }
}

1;

// note this also doens't use `%` (although it does... whoops)
i,j,z;char*f[675],**a=f+1;main(){for(;i<300;++a){f[i+=3]="Fizz",f[j+=5]="Buzz",f[(z+=15)%105]="FizzBuzz",printf(*a?"%s\n":"%d\n",*a?*a:a-f);}}

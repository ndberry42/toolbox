#!/usr/bin/perl

sub randomPassword {
 my $password;
 my $_rand;

 my $password_length = $_[0];
 if (!$password_length) {
  $password_length = 14;
 }

 my @chars = split(" ",
 "a b c d e f g h i j k l m n o
  p q r s t u v w x y z A B C D
  E F G H I J K L M N O P Q R S
  T U V W X Y Z - _ % # | 0 1 2 
  3 4 5 6 7 8 9 ! ? $ @");

 srand;

 for (my $i=0; $i <= $password_length ;$i++) {
  $_rand = int(rand 71);
  $password .= $chars[$_rand];
 }
 return $password;
}

print "\n\nRandom Password = ", randomPassword(13);
print "\n\n";

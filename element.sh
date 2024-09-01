#!/bin/bash

# Connect to the database with a specific username and database name
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# If no argument is provided, output an error message
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit 0
fi

# Determine whether the input is a number or not
if [[ $1 =~ ^[0-9]+$ ]]
then
  # If input is a number, search by atomic number
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1")
else
  # If input is not a number, search by symbol or name
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$1' OR name='$1'")
fi

# If atomic number is not found, return an error
if [[ -z $ATOMIC_NUMBER ]]
then
  echo "I could not find that element in the database."
  exit 0
fi

# Retrieve element details from the database
ELEMENT_INFO=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, t.type 
                     FROM elements e 
                     INNER JOIN properties p ON e.atomic_number = p.atomic_number 
                     INNER JOIN types t ON p.type_id = t.type_id 
                     WHERE e.atomic_number = $ATOMIC_NUMBER")

# Split the information into separate variables
IFS="|" read ATOMIC_NUMBER NAME SYMBOL ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE <<< "$ELEMENT_INFO"

# Output the formatted information
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."

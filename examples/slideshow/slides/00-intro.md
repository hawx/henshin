---
name: Intro
---


$$$ center
# Intro

What is this? A slideshow!

$$$ bullets incremental
# How Does It Work

- Create a `slides.yml`
- Create a `slides/` folder 
- Add some markdown files
- Separate slides using $$$

$$$ code
    
    $$$ center
    # Intro
    
    What is this? A slideshow!
    
    
    $$$ bullets incremental
    # Recursion, Or What?
    
    Like this, BOOM!
    Boom
    boom
    ....


$$$
# Formatting/Transitions????

To vertically center stuff

    $$$ center


$$$
# Formatting/Transitions????
 
To show the next item instead of advancing page
 
    $$$ incremental bullets


$$$
# And the rest

    $$$ full-image
    $$$ bullets


$$$ incremental bullets
# Navigation

- j, right, space = next  
- k, left = previous  
- c = show list of slides


$$$ code

$ highlight ruby
def code
  @@codes = true
end
$ end
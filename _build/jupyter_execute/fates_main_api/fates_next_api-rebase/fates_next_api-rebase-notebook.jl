using Makie, AbstractPlotting
using Images, ImageView
using TestImages

timg = testimage("lighthouse")

typeof(timg)

image(timg)

img = "Test-Cases/Long-Term/gridded/pftleafbiomass_pft-12_main-next_and_map.png"
loadedimg = load(img)
typeof(loadedimg)


imshow(loadedimg)





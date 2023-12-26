
Instructions updating the try-ssd.yaml
- clone this repo to local
- cd charts/ssd
- ```helm template ssd . -n try-ssd  -f rcimages-values.yaml -f minimal-local-values.yaml > ../..try-ssd.yaml```
- push to the repo
- Test it once EXACTLY following the instructions in the README
  

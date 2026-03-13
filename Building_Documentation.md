#  Building Documentation

Generate the docs 

```sh
swift package --allow-writing-to-directory ./docs \
    generate-documentation --target Sliders \
    --disable-indexing \
    --transform-for-static-hosting \
    --hosting-base-path Sliders-SwiftUI \
    --output-path ./docs
```

Test the webpage locally

```sh
swift package --disable-sandbox preview-documentation --target Sliders
```



AppIconOverlay
==============

Create an overlay on top of your app icon

Options
=======

**--input,-i**: image file to read in. You can specify more than one file to input and output, when done the inputs will be matched to the outputs so there must be the same number of each.

**--output,-o**: output image file

**--text,-t**: text to put on banner

**--height,-h**: height of banner

**--padding,-p**: padding around banner text

**--font,-f**: font to use (defaults to 'Arial-BoldMT')

Example Output
==============

![example 144](https://raw.github.com/carsonmcdonald/AppIconOverlay/master/examples/example-144.png "example 144") &nbsp;
![example 114](https://raw.github.com/carsonmcdonald/AppIconOverlay/master/examples/example-114.png "example 114") &nbsp;
![example 72](https://raw.github.com/carsonmcdonald/AppIconOverlay/master/examples/example-72.png "example 72") &nbsp;
![example 57](https://raw.github.com/carsonmcdonald/AppIconOverlay/master/examples/example-57.png "example 57") &nbsp;

The above examples where created using the following command:

```shell
AppIconOverlay -i input.png -o output.png --text v1.2.3 -h 19.0
```

## License

MIT, see the LICENSE file for full license.

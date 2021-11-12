The following configurations have not been tested (YET):

- CPC664 (may support single density)
- CPC with 4 true drives modification
- DDI-1 (expected that single density is supported with some versions)
- Vortex Disc interface
- KC Compact disc interface
- Aleste 520EX
- HxC or Gotek

NOTE: 
- On CPC, if you set 'DMA' mode, then turn it off, every read after will generate 
a read error. This differs from Plus which generates an overrun. Therefore dma tests are at 
the end. The reason for the difference is not yet fully known.
- There are small differences between FDC models
- Some tests are checking timings. There may be a difference between the results
expected by the test and the results you see. If you can help improve the tests to
make them more accurate and more reliable please contact me.




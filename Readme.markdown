Maximize SWF Compression
=

Minimize bandwidth costs and reduce page latency by decreasing the total size of your
swf assets.

Usage
-
    swf_recompress [options] swf_filename [output_swf_filename]
      -i, --in-place                   Compress the swf in-place, replacing the original file
      -a, --acquire-kzip               Download kzip tool
      -v, --version                    Show version & contributors
      -h, --help                       Show this message

If only one filename is given and the -i flag is not supplied, a new swf
with the suffix <tt>_compressed</tt> will be created alongside the original file.

Thanks
-
* Jos-Iven Hirth's [Improving SWF Compression](http://kaioa.com/node/87)
* Ken Silverman's [kzip](http://advsys.net/ken/utils.htm)
* Jonathan Fowler's [Mac OS X and Linux binaries](http://www.jonof.id.au/)

License
-
As most of the code is based on Jos-Iven Hirth's work, this work is released
under the same license.

> **Zero-clause BSD-style license (DGAF)**

> Redistribution and use in source and binary forms, with or without
> modification, are permitted.

> THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
> "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
> LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
> A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
> OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
> SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
> LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
> DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
> THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
> (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
> OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

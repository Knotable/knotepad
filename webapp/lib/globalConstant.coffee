class @CommonRegularExpressions
  #Don't create actual regular expressions here, just strings with sources. RegExps have states which may lead to errors.
  @constants do ->
    properties =
      scheme: "[a-z\\d.-]+://"
      ipv4: "(?:(?:[0-9]|[1-9]\\d|1\\d{2}|2[0-4]\\d|25[0-5])\\.){3}(?:[0-9]|[1-9]\\d|1\\d{2}|2[0-4]\\d|25[0-5])"
      hostname: "(?:(?:[^\\s!@#$%^&*()_=+[\\]{}\\\\|;:'\",.<>/?]+)\\.)+"
      tld: "(?:ac|ad|aero|ae|af|ag|ai|al|am|an|ao|aq|arpa|ar|asia|as|at|au|aw|ax|az|ba|bb|bd|be|bf|bg|bh|biz|bi|bj|bm|bn|bo|br|bs|bt|bv|bw|by|bz|cat|ca|cc|cd|cf|cg|ch|ci|ck|cl|cm|cn|coop|com|co|cr|cu|cv|cx|cy|cz|de|dj|dk|dm|do|dz|ec|edu|ee|eg|er|es|et|eu|fi|fj|fk|fm|fo|fr|ga|gb|gd|ge|gf|gg|gh|gi|gl|gm|gn|gov|gp|gq|gr|gs|gt|gu|gw|gy|hk|hm|hn|hr|ht|hu|id|ie|il|im|info|int|in|io|iq|ir|is|it|je|jm|jobs|jo|jp|ke|kg|kh|ki|km|kn|kp|kr|kw|ky|kz|la|lb|lc|li|lk|lr|ls|lt|lu|lv|ly|ma|mc|md|me|mg|mh|mil|mk|ml|mm|mn|mobi|mo|mp|mq|mr|ms|mt|museum|mu|mv|mw|mx|my|mz|name|na|nc|net|ne|nf|ng|ni|nl|no|np|nr|nu|nz|om|org|pa|pe|pf|pg|ph|pk|pl|pm|pn|pro|pr|ps|pt|pw|py|qa|re|ro|rs|ru|rw|sa|sb|sc|sd|se|sg|sh|si|sj|sk|sl|sm|sn|so|sr|st|su|sv|sy|sz|tc|td|tel|tf|tg|th|tj|tk|tl|tm|tn|to|tp|travel|tr|tt|tv|tw|tz|ua|ug|uk|um|us|uy|uz|va|vc|ve|vg|vi|vn|vu|wf|ws|xn--0zwm56d|xn--11b5bs3a9aj6g|xn--80akhbyknj4f|xn--9t4b11yi5a|xn--deba0ad|xn--g6w251d|xn--hgbk6aj7f53bba|xn--hlcj6aya9esc7a|xn--jxalpdlp|xn--kgbechtv|xn--zckzah|ye|yt|yu|za|zm|zw)"
      path: "(?:[;/][^#?<>\\s]*)?"
      query_frag: "(?:\\?[^#<>\\s]*)?(?:#[^<>\\s]*)?"
      mailto: "mailto:"

    properties.host_or_ip           = "(?:" + properties.hostname + properties.tld + "|" + properties.ipv4 + ")"
    properties.uri1                 = "\\b" + properties.scheme + "[^<>\\s]+"
    properties.uri2                 = "\\b" + properties.host_or_ip + properties.path + properties.query_frag + "(?!\\w)"
    properties.email_without_mailto = "[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@" + properties.host_or_ip + properties.query_frag + "(?!\\w)"
    properties.email                = "(?:" + properties.mailto + ")?" + properties.email_without_mailto
    properties.uri                  = "(?:" + properties.uri1 + "|" + properties.uri2 + "|" + properties.email + ")"
    properties.knotableDomainTester = "knotable\\.com"
    return properties
@CommonRegularExpressions = new @CommonRegularExpressions


@URL_REGEX = /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.; ]*[-A-Z0-9+&@#\/%=~_|])/ig

@EXAMPLE_CONTACTS = [
  "amol@help.knote.com"
  "sallysallyshoes@gmail.com"
  "mollymollydress@gmail.com"
  "caseycaseypants@gmail.com"
  "amiramirhats@gmail.com"
  "darbydarbysocks@gmail.com"
  "ryanryanscarf@gmail.com"
]


class @SignupMethods
  @constants
    knoteUp: 7
@SignupMethods = new @SignupMethods

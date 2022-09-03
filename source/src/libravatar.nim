from md5 import getMD5

proc getLibravatarUrl*(email: var string, size: range[1..512] = 100,
    default: static[string] = "robohash", forceDefault: static[bool] = false,
    baseUrl: static[string] = (when defined(ssl): "https://seccdn.libravatar.org/avatar/" else: "http://cdn.libravatar.org/avatar/")) =
  ## https://wiki.libravatar.org/api & https://wiki.libravatar.org/features
  ## Federation supported passing ``baseUrl``, DNS server discovery is up to you.
  ## Nim being compiled, dont need a hardcoded DNS dig at Runtime in this function,
  ## you can do it compile-time for your needs, or just pass a string URL, KISS.
  ## 404 wont return 404,but a default image,use ``default="404"`` for 404 Error.
  ## Your users nor you dont need a Libravatar account if you dont want to,
  ## because if Libravatar cant find you it redirects you to your Gravatar,
  ## if you have no Gravatar then it returns a default autogenerated image.
  assert email.len > 5, "email must not be empty string"
  assert email.len < 255, "email must be <255 characters long string"
  assert '@' in email, "email must be a valid standard email address string"
  assert baseUrl.len > 5, "baseUrl must be a valid HTTP URL string"
  email = baseUrl & getMD5(email)
  email.add '?'
  email.add 's'
  email.add '='
  email.add $size
  email.add (when default != "": "&d=" & default else: "")
  email.add (when defined(release): "" else: (when forceDefault: "&f=y" else: ""))


runnableExamples:
  var email = "me@aaronsw.com"
  getLibravatarUrl(email)
  echo email
  email = "me@aaronsw.com"
  getLibravatarUrl(email, size = 512, default = "monsterid")
  echo email


when isMainModule and defined(ssl):
  import httpclient
  from os import paramStr
  var email = paramStr(1)
  getLibravatarUrl(email, size = 128, default = "404")
  newHttpClient().downloadFile(email, paramStr(1) & ".jpg")
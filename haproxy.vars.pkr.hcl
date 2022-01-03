variable "base_image_registry" { 
    type = string 
}
variable "base_image_tag" {
    type = string 
}

variable "haproxy_image_registry" {
    type = string 
}
variable "haproxy_image_release" { 
    type = string 
}

variable "haproxy_release_major" { 
    type = string 
}
variable "haproxy_release_minor" { 
    type = string 
}
variable "haproxy_sha512" {
    type = string 
}

variable "lua_release" { 
    type = string 
}
variable "lua_sha512" { 
    type = string 
}

variable "openssl_release" { 
    type = string 
}
variable "openssl_sha512" { 
    type = string 
}

variable "pcre2_release" { 
    type = string 
}
variable "pcre2_sha512" { 
    type = string 
}
require 'base64'
require 'logger'
module Cantaloupe

  ##
  # Tells the server whether the given request is authorized. Will be called
  # upon all image requests to any endpoint.
  #
  # Implementations should assume that the underlying resource is available.
  #
  # @param identifier [String] Image identifier
  # @param full_size [Hash<String,Integer>] Hash with "width" and "height"
  #                                         keys corresponding to the pixel
  #                                         dimensions of the source image.
  # @param operations [Array<Hash<String,Object>>] Array of operations in
  #                   order of execution. Only operations that are not no-ops
  #                   will be included. Every hash contains an "operation" key
  #                   corresponding to the type of operation. See the Javadoc
  #                   of e.i.l.c.image.Operation implementations for a list of
  #                   possible operations.
  # @param resulting_size [Hash<String,String>] Hash with "width" and "height"
  #                       keys corresponding to the pixel dimensions of the
  #                       resulting image after all operations are applied.
  # @param output_format [Hash<String,String>] Hash with "media_type" and
  #                                            "extension" keys.
  # @param request_uri [String] Full request URI
  # @param request_headers [Hash<String,String>]
  # @param client_ip [String]
  # @param cookies [Hash<String,String>]
  # @return [Boolean] Whether the request is authorized based on the supplied
  #                   arguments.
  #
  def self.authorized?(identifier, full_size, operations, resulting_size,
                       output_format, request_uri, request_headers, client_ip,
                       cookies)
    true
  end

  ##
  # Used to add additional keys to the information JSON response. including
  # `attribution`, `license`, `logo`, `service`, and custom keys. See
  # {http://iiif.io/api/image/2.1/#image-information the Image API
  # specification}.
  #
  # @param identifier [String] Image identifier
  # @return [Hash] Hash that will be merged into IIIF Image API 2.x
  #                information responses. Return an empty hash to add nothing.
  #
  def self.extra_iiif2_information_response_keys(identifier)
=begin
    Example:
    {
        'attribution' =>  'Copyright My Great Organization. All rights '\
                          'reserved.',
        'license' =>  'http://example.org/license.html',
        'logo' =>  'http://example.org/logo.png',
        'service' => {
            '@context' => 'http://iiif.io/api/annex/services/physdim/1/context.json',
            'profile' => 'http://iiif.io/api/annex/services/physdim',
            'physicalScale' => 0.0025,
            'physicalUnits' => 'in'
        }
    }
=end
    {}
  end

  ##
  # Tells which resolver to use for the given identifier.
  #
  # @param identifier [String] Image identifier
  # @return [String] Resolver name
  #
  def self.get_resolver(identifier)
  end

  module FilesystemResolver

    ##
    # @param identifier [String] Image identifier
    # @return [String,nil] Absolute pathname of the image corresponding to the
    #                      given identifier, or nil if not found.
    #
    def self.get_pathname(identifier)
    end

  end

  module AmazonS3Resolver

    ##
    # @param identifier [String] Image identifier
    # @return [String,nil] S3 object key of the image corresponding to the
    #                      given identifier, or nil if not found.
    #
    def self.get_object_key(identifier)
    end

  end

  module AzureStorageResolver

    ##
    # @param identifier [String] Image identifier
    # @return [String,nil] Blob key of the image corresponding to the given
    #                      identifier, or nil if not found.
    #
    def self.get_blob_key(identifier)
    end

  end

  module HttpResolver
    ##
    # @param identifier [String] Image identifier
    # @return [String,nil] URL of the image corresponding to the given
    #                      identifier, or nil if not found.
    #
    def self.get_url(identifier)
      logger = Logger.new(STDOUT)
      logger.level = Logger::DEBUG
      logger.info("Base64 identifier: #{identifier}")
      logger.info("Decoded identifier: #{Base64.urlsafe_decode64(identifier)}")
      Base64.urlsafe_decode64(identifier)
    end

  end

  module JdbcResolver

    ##
    # @param identifier [String] Image identifier
    # @return [String] Identifier of the image corresponding to the given
    #                  identifier in the database.
    #
    def self.get_database_identifier(identifier)
    end

    ##
    # Returns an SQL statement that can be used to retrieve the media (MIME)
    # type of an image. If the media type is
    # stored in the database, this can return an SQL statement to retrieve it,
    # in which case the "SELECT" and "FROM" clauses should be in uppercase in
    # order to be autodetected. If commented out, the media type will be
    # inferred from the identifier extension (if present).
    #
    def self.get_media_type
    end

    ##
    # Returns an SQL statement that selects the BLOB corresponding to the value
    # returned by get_database_identifier.
    #
    def self.get_lookup_sql
    end

  end

  ##
  # Tells the server what regions of an image to redact in response to a
  # particular request. Will be called upon all image requests to any
  # endpoint if `redaction.enabled` is set to `true` in the configuration
  # file.
  #
  # @param identifier [String] Image identifier
  # @param request_headers [Hash<String,String>]
  # @param client_ip [String]
  # @param cookies [Hash<String,String>]
  # @return [Array<Hash<String,Integer>>] Array of hashes, each with `x`, `y`,
  #         `width`, and `height` keys; or an empty array if no redactions are
  #         to be applied.
  #
  def self.redactions(identifier, request_headers, client_ip, cookies)
    []
  end

  ##
  # Tells the server what watermark, if any, to apply to an image in response
  # to a particular request. Will be called upon all image requests to any
  # endpoint if `watermark.enabled` is set to `true` and `watermark.strategy`
  # is set to `ScriptStrategy` in the configuration file.
  #
  # @param identifier [String] Image identifier
  # @param operations [Array<Hash<String,Object>>] Array of operations in
  #                   order of execution. Only operations that are not no-ops
  #                   will be included. Every hash contains an "operation" key
  #                   corresponding to the type of operation. See the Javadoc
  #                   of e.i.l.c.image.Operation implementations for a list of
  #                   possible operations.
  # @param resulting_size [Hash<String,String>] Hash with "width" and "height"
  #                       keys corresponding to the pixel dimensions of the
  #                       resulting image after all operations are applied.
  # @param output_format [Hash<String,String>] Hash with "media_type" and
  #                                            "extension" keys.
  # @param request_uri [String] Full request URI
  # @param request_headers [Hash<String,String>]
  # @param client_ip [String]
  # @param cookies [Hash<String,String>]
  # @return [Hash<String,String>,Boolean] 3-element hash with `pathname`,
  #         `position`, and `inset` keys; or false to not apply a watermark.
  #
  def self.watermark(identifier, operations, resulting_size, output_format,
                     request_uri, request_headers, client_ip, cookies)
    false
  end

end

# Uncomment to test on the command line (`ruby delegates.rb`)
# puts Cantaloupe::FilesystemResolver::get_pathname('image.jpg')

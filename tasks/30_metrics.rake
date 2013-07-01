if @build.benchmark
  @metrics          = []
  @pg_major_version = nil

  def add_metrics args
    @metrics << {
      :bench      => args[:bench],
      :dist       => ( args[:dist]        || ENV['DIST']       ),
      :pkg        => ( args[:pkg]         || @build.project    ),
      :version    => ( args[:version]     || @build.version    ),
      :pe_version => ( args[:pe_version]  || @build.pe_version ),
      :date       => ( args[:date]        || timestamp         ),
      :who        => ( args[:who]         || ENV['USER']       ),
      :where      => ( args[:where]       || hostname          ),
      :success    => ( args[:success]     || false             ),
      :log        => ( args[:log]         || "Not available"   )
    }
  end

  def post_metrics
      metric_server = "http://dagr.delivery.puppetlabs.net:4567/overview/metrics"
      @metrics.each do |metric|
        date        = metric[:date]
        pkg         = metric[:pkg]
        dist        = metric[:dist]
        bench       = metric[:bench]
        who         = metric[:who]
        where       = metric[:where]
        version     = metric[:version]
        pe_version  = metric[:pe_version]
        success     = metric[:success]
        log         = metric[:log]

      uri = URI(metric_server)
      res = Net::HTTP.post_form(
        uri,
        {
          'date'                => Time.now.to_s,
          'package_name'        => pkg,
          'dist'                => dist,
          'package_build_time'  => bench,
          'build_user'          => who,
          'build_loc'           => where,
          'version'             => version,
          'pe_version'          => pe_version,
          'success'             => success,
          'build_log'           => log,
        })
    end
    @metrics = []
  end
end

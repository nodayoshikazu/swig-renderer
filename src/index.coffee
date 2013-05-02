#
#   index.coffee
#     Swig template renderer command line tool
#
# 
_       = require('underscore')
should  = require('should')
swig    = require('swig')
program = require('commander')
fs      = require('fs')



module.exports = class SwigRenderer
    vars = null
    swig_tmpls = []
    jsonfile = null

    #
    # Create SwigRenderer object
    #  actually does the rendering.
    # 
    constructor: (jsonfile, swigs) ->
        should.exist(swigs)
        @swig_tmpls = swigs
        @jsonfile = jsonfile

    #
    # Run and render the output to stdout
    # 
    run: ()->
        if @jsonfile
            fs.exists @jsonfile, (exists) =>
                if exists
                    try
                        @vars  = JSON.parse(fs.readFileSync(@jsonfile))
                    catch err
                        console.log 'Error: malformed JSON'
                        return -1
                    @_render()
                else
                    console.log "Error: file #{jsonfile} doesn\'t exist"
                    process.exit(1)
        else
            @_do_stdin()

    #
    # Input JSON from stdin.
    # 
    _do_stdin: () ->
        process.stdin.resume()
        process.stdin.setEncoding('utf8')
        process.stdin.on 'data', (chunk) =>
            if not chunk.match /^[ \t\n]*$/g
                try
                    @vars = JSON.parse(chunk)
                catch err
                    console.log 'Error: malformed JSON'
                    return -1
            
        process.stdin.on 'end', () =>
            @_render()
        
    #
    # Render the template with the variables defined in the JSON file.
    # 
    _render: () ->
        if not @vars
            console.log 'Error: no replacement variables are defined'
        else
            _.each @swig_tmpls, (tmpl) =>
                if not tmpl.match /^\/.*$/g
                    path = process.cwd() + '/' + tmpl
                else
                    path = tmpl
                exists = fs.existsSync(tmpl)
                # Actually it shouldn't be a fatal error if a template file doesn't exist
                if exists
                    t = swig.compileFile(path)
                    r = t.render(@vars)
                    console.log r
                else
                    console.log "Error: #{tmpl} does not exist"

# Run it
program
    .version('0.0.1')
    .usage('[options] <file ...>')
    .option('-f, --file <file>', 'JSON file name')
    .parse(process.argv)
    
swigRenderer = new SwigRenderer(program.file, program.args)
swigRenderer.run()



from subutai_bazaar import cdn
import optparse
import sys
import os.path

if __name__ == '__main__':
    parser = optparse.OptionParser()
    parser.add_option('-t', '--host', action='store', dest='host',
                      help='hostname of the CDN', default='bazaar.subutai.io')
    parser.add_option('-f', '--file', action='store', dest='srcfile',
                      help='file to upload', default='')
    parser.add_option('-u', '--user', action='store', dest='gpguser',
                      help='GPG key ID', default='')
    parser.add_option('-p', '--fingerprint',
                      action='store',
                      dest='fingerprint',
                      help='GPG fingerprint',
                      default='')

    options, args = parser.parse_args()

    if options.srcfile == '':
        print("Specify source file with --file=<pathtofile> option")
        sys.exit(2)

    if options.gpguser == '':
        print("Specify GPG key ID with --user=<id> option")
        sys.exit(3)

    if options.fingerprint == '':
        print("Specify fingerprint with --fingerprint=<fingerprint> option")
        sys.exit(4)

    if not os.path.isfile(options.srcfile):
        print("Specified file was not found")
        sys.exit(5)

    c = cdn.CDN(options.host,
                user=options.gpguser,
                fingerprint=options.fingerprint)
    try:
        result = c.Upload(options.srcfile)
        if result is None:
            print("File upload failed")
            sys.exit(2)
        print("File was succesfully uploaded")
    except Exception as e:
        print("Error occured during upload: " + str(e))
        sys.exit(2)

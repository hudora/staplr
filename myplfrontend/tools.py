

def format_locname(locname):
    """ Formats a location name nicely. """
    if len(locname) == 6 and str(locname).isdigit():
        return "%s-%s-%s" % (locname[:2], locname[2:4], locname[4:])
    return locname

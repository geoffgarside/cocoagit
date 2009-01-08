# I can't figure out how to access the GITError constants
# define them here for now
module GITError
  ObjectSizeMismatch = -1
  ObjectNotFound = -2
  ObjectTypeMismatch = -3
  ObjectParsingFailed = -4
  
  FileNotFound = -5
  
  PackIndexUnsupportedVersion = -6
  PackStoreNotAccessible = -7
  PackFileInvalid = -8
  PackFileNotSupported = -9
end

# MacRuby does not define == in terms of NSObject#isEqual
# Define == for the core GIT classes so that assert_equal
# works properly
class GITObject
  def ==(other)
    self.isEqualTo other
  end
end

# TODO: Replace this with an ObjC version that returns a dictionary.
#       We also need a method to return a list of parents.
class GITCommit
  def to_hash
    {
      'id'       => sha1,
      'parents'  => { 'id' => parentSha1 },  # we don't support multiple parents yet
      'tree'     => tree.sha1,
      'message'  => message.strip,
      'author'   => {
        'name'  => author.name,
        'email' => author.email
      },
      'committer' => {
        'name'  => committer.name,
        'email' => committer.email
      },
      'authored_date'  => authored.to_s,
      'committed_date' => committed.to_s
    }
  end
end

class GITDateTime
  # return a string representation of the NSDate + Timezone info
  def to_s
    self.date.descriptionWithCalendarFormat "%a %b %d %H:%M:%S %Y %z", timeZone:self.timezone, locale:nil
  end
end
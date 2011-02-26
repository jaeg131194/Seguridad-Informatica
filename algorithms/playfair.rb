module Algorithms
  class Playfair
    class << self # hereda de si mismo, definimos metodos de Clase, no de instancia    
      # Encrypt a msg using playfair cyper method.
      # You need to give the msg, and the keyword with wich
      #  will be used to encrypt.
      def encrypt(msg, keyword=nil)          
        # Ensure arguments have no spaces and exists
        sanitize_args(msg,keyword)
        
        # Define and fill our matrix
        define_matrix
       
        # Apply first rule to the message
        first_rule       
        
        # Play in the matrix to finally encrypt the msg
        finally_encrypt       
      
      end      
      
      private
        def sanitize_args(msg, keyword)
          raise ArgumentError, "Un argumento esta vacio" if msg.empty?
          keyword = ask_keyword if keyword.nil?
          @msg, @keyword  =   msg.delete(" "),  keyword.delete(" ")   #get rid of spaces
        end
        
        def ask_keyword
          p "Enter passphrase: "
          gets.chomp
        end
        
        def define_matrix
          # Creates a 5x5 matrix that will help for the encryption and decription.
          @matrix = [ Array.new(5), Array.new(5), Array.new(5),
                      Array.new(5), Array.new(5) ]
          fill_matrix
        end
        
          def fill_matrix
            # change every 'j' with and 'i'
            keyword   = @keyword.gsub(/j/, 'i')
            # define an alphabet
            alphabet  = ("a".."z").to_a - keyword.split(//) - ['j'] # Quitamos la `j` porque se toma como `i`
            used_letters = []
            
            ## Llenado de matriz
            @matrix.each_index do |index|
              @matrix[index].each_index do |inner_index|
                begin
                  letter  = (keyword.slice!(0) || alphabet.delete_at(0))
                end while (not  letter.nil?           and 
                           not  used_letters.empty?   and 
                           used_letters.include?(letter))                      
                used_letters  <<  letter            # la agregamos al arreglo de letras usadas.
                @matrix[index][inner_index] = letter # y llenamos la matriz.      
              end
            end
          end
        
        # Apply the fist rule to the encryption process.
        
        def first_rule
          # helper variable to iterate over the word in pairs.        
          index         =   0          
          while index < @msg.size
            @msg.insert(index+1, 'x') if @msg[index] == @msg[index+1]
            index +=  2
          end          
          #Add an X to the end if the msg is odd.
          @msg += 'x' if @msg.size.odd?   
        end
        
        # Play with the matrix applying all the rules that this algorithm has
        # in order to finish with the encryption
        def finally_encrypt
          @encrypted_msg  = ''
          # Smelly code. giak! try to refactor using a function that iterates and yields a pair of chars.
          index = 0
          while index < @msg.size
            # Get coords for each pair of chars.            
            a_coords  = find_char_in_matrix(@msg[index])
            b_coords  = find_char_in_matrix(@msg[index+1])
            
            # Apply rules of movement in the key matrix
            movement_in_matrix(a_coords,b_coords)      
                  
            index +=  2
          end
          @encrypted_msg
        end
        
        def find_char_in_matrix(char)
          x , y = nil , nil
          y = @matrix.find_index{|first| x = first.find_index{|second| second == char} }
          return [x,y] if not x.nil? and not y.nil?
          raise "No existe la letra en la matriz de llave" if x.nil? or y.nil?
        end
        
        def movement_in_matrix(a_coords,b_coords)
          # Keep ALL the coords in a hash to facilitate manipulation.
          coords  = Hash.new()
          coords[:x1],  coords[:y1] = a_coords[0],  a_coords[1]
          coords[:x2],  coords[:y2] = b_coords[0],  b_coords[1]
          same_row(coords)
          same_column(coords)
          cross(coords)
        end 
               
        def same_row(coords)
          if coords[:y1] == coords[:y2]
            rotate_right = @matrix[coords[:y1]].rotate
            @encrypted_msg += rotate_right[coords[:x1]] + rotate_right[coords[:x2]]
          end
        end
        
        def same_column(coords)
          if coords[:x1] == coords[:x2]
            rotate_down = @matrix.rotate
            @encrypted_msg  +=  rotate_down[coords[:y1]][coords[:x1]] + rotate_down[coords[:y2]][coords[:x2]]
          end
        end
        
        def cross(coords)
          if coords[:x1] != coords[:x2] and coords[:y1] != coords[:y2]
            @encrypted_msg += @matrix[coords[:y1]][coords[:x2]] + @matrix[coords[:y2]][coords[:x1]]
          end
        end
        
     end # class methods
  end # class
end # module

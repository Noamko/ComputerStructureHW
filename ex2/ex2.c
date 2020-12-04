// 308192871 Noam Koren

// Happy Cheking :) //
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define CARRIAGE_RETURN 0x000d
#define LINE_FEED 0x000a
#define BYTE_SIZE 8
#define COPY 3
#define COPY_SPECIFIC_OS 5
#define COPY_SPECIFIC_OS_SWAP 6
#define SWAP 1

/**
 * swap_bytes get a 16 bit char(short) 
 * we shift it to the left 8 bits zero out anything that might be added to to diffrent machine using shift
 * we then do the same but using right shift 
 * lastly we combine them using bitwise OR
*/
short swap_bytes(short s) {
    return ((s << BYTE_SIZE) & 0xFF00) | ((s >> BYTE_SIZE) & 0x00FF);
}

/**
 * Write End of Line function
 * this function will be called every time we need to write a new line ending 
 * depending on the dest oparating system we will insert a diffrent line ending
 * we acount for diffrent bom orders using the previusly declared swap byte function
 * to match the big/little endien architecture
 */
void write_eol(FILE* outfile, char* dst_os, unsigned short bom, int swap) {
    short carriage_return = CARRIAGE_RETURN, line_feed = LINE_FEED;
    if (bom == 0xFFFE) {
        line_feed = swap_bytes(line_feed);
        carriage_return = swap_bytes(carriage_return);
    }
    if (swap) {
        carriage_return = swap_bytes(carriage_return);
        line_feed = swap_bytes(line_feed);
    }
    if (strcmp(dst_os, "-unix") == 0) {
        fwrite(&line_feed, sizeof(short), 1, outfile);
    } 
    else if (strcmp(dst_os, "-mac") == 0) {
        fwrite(&carriage_return, sizeof(short), 1, outfile);
    } 
    else if (strcmp(dst_os, "-win") == 0) {
        fwrite(&carriage_return, sizeof(short), 1, outfile);
        fwrite(&line_feed, sizeof(short), 1, outfile);
    }
}

/**
 * Write to file Function
 * this function go byte by byte on the source file 
 * and writing it to a new file following given flags rules
 * flag rules as follows: <srcFile> <dstFile> <srcOS> <dstOs> <swap>
 * since we are using UTF-16 we will store the chars as short
 * since short hold 2 bytes.
 * we then read each byte storing it on a short then write it to the new file
 * and if we encounter line ending we will write the need line ending depanding on the flag that was given
 * and if we want to match the file to big/little endien systems we will use the swap flag
 * and switch between the short bytes.
 */
void writefile(FILE* in, FILE* out, char* srcOS, char* dstOS, int swap) {
    char eof = 1; //end of file indicator
    char newline = 0; //new line indicator
    char bomchecker = 0; //bom indicator
    unsigned short bom; //current bom
    unsigned short curr_char = 0; //current char
    unsigned short prev_char = 0; //previues char
    unsigned short lf = LINE_FEED;
    unsigned short cr = CARRIAGE_RETURN;

    //go trough all the file untill eof will be set to 0.
    while (eof == 1) {
        eof = fread(&curr_char, sizeof(short), 1, in);
        
        //get src file BOM
        if (!bomchecker) {
            bom = curr_char;
            if (bom == 0xFFFE) {
                lf = swap_bytes(lf);
                cr = swap_bytes(cr);
            }
            bomchecker = 1; //set the bom checker to 1 so we wont change it agian.
        }
        if (eof != 1) {
            break;
        }
        if (swap) { //swap
            curr_char = swap_bytes(curr_char);
        }
        if (strcmp(srcOS, "-win") == 0) {  // windows line ending
            if (swap) {
                if (curr_char == swap_bytes(lf) && prev_char == swap_bytes(cr)) { //eol detected.
                    newline = 1;
                    write_eol(out, dstOS, bom, swap);
                } else {
                    if (prev_char != 0 && !newline) {
                        fwrite(&prev_char, sizeof(short), 1, out); //just write the char.
                    }
                    if (newline) {
                        newline = 0;
                    }
                }
            } else {
                if (curr_char == lf && prev_char == cr) { //eol detected.
                    newline = 1;
                    write_eol(out, dstOS, bom, swap);
                } else {
                    if (prev_char != 0 && !newline) {
                        fwrite(&prev_char, sizeof(short), 1, out);
                    }
                    if (newline) {
                        newline = 0;
                    }
                }
            }
            prev_char = curr_char;
        }

        else if (strcmp(srcOS, "-unix") == 0) { //unix line ending
            if (swap) {
                if (curr_char == swap_bytes(lf)) { //eol detected.
                    write_eol(out, dstOS, bom, swap);
                } else {
                    fwrite(&curr_char, sizeof(short), 1, out);
                }
            } else {
                if (curr_char == lf) {
                    write_eol(out, dstOS, bom, swap);
                } else {
                    fwrite(&curr_char, sizeof(short), 1, out);
                }
            }
        }

        else if (strcmp(srcOS, "-mac") == 0) { //macOS line ending
            if (swap) {
                if (curr_char == swap_bytes(cr)) { //eol detected.
                    write_eol(out, dstOS, bom, swap);
                } else {
                    fwrite(&curr_char, sizeof(short), 1, out);
                }
            } else {
                if (curr_char == cr) {
                    write_eol(out, dstOS, bom, swap);
                } else {
                    fwrite(&curr_char, sizeof(short), 1, out);
                }
            }
        }
    }
}
/**
 * Copy file
 * this function copy the file byte by byte
 * store it to a new file
 */
void copy_file(FILE* in, FILE* out) {
    short curr_char = -1;
    int eof = 1;
    while (eof == 1) {
        eof = fread(&curr_char, 2, 1, in);
        if (eof != 1) {
            break;
        }
        fwrite(&curr_char, 2, 1, out);
    }
}

/**
 * main function
 */
int main(int argc, char* argv[]) {
    FILE* ifile;
    FILE* ofile;
    ifile = fopen(argv[1], "rb");
    if (ifile == NULL || argc < COPY || argc == 4) {
        return 0;
    }
    if (argc == COPY) { //check that we have a valid flags
        if (strcmp(argv[2], "-unix") == 0 || strcmp(argv[2], "-mac") == 0 ||
            strcmp(argv[2], "-win") == 0 || strcmp(argv[2], "-swap") == 0 ||
            strcmp(argv[2], "-keep") == 0) {
            fclose(ifile);
            return 0;
        }
        ofile = fopen(argv[2], "wb"); // open output file
        copy_file(ifile, ofile);
        fclose(ofile);
    } 
    else if (argc == COPY_SPECIFIC_OS) { 
        ofile = fopen(argv[2], "wb");
        writefile(ifile, ofile, argv[3], argv[4], 0);
        fclose(ofile);
    }
    else if (argc == COPY_SPECIFIC_OS_SWAP) {
        ofile = fopen(argv[2], "wb");
        if (strcmp(argv[5], "-swap") == 0) {
            writefile(ifile, ofile, argv[3], argv[4], SWAP);
        } 
        else if (strcmp(argv[5], "-keep") == 0) {
            writefile(ifile, ofile, argv[3], argv[4], !SWAP);
        }
        fclose(ofile);
    }
    fclose(ifile);
    return 0;
}
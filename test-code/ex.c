#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <openssl/aes.h>
#include <openssl/md5.h>

int decrypt_AES128ECB(unsigned char *key, unsigned char *cypher, unsigned char *plain, int len)
{
    AES_KEY deckey;

    if(0 != (len % AES_BLOCK_SIZE)) {
        printf("Cypher length should be a multiple of AES_BLOCK_SIZE\n");
        return -1;
    }

    if (AES_set_decrypt_key(key, 128, &deckey) < 0) {
        printf("Set decryption key in AES failed\n");
        return -2;
    }

    while(len) {
        AES_ecb_encrypt(cypher, plain, &deckey, AES_DECRYPT);-
        len -= AES_BLOCK_SIZE;
        cypher += AES_BLOCK_SIZE;
        plain += AES_BLOCK_SIZE;
    }

    return 0;
}

int main(void)
{
    unsigned char Rfd, Wfd;
    unsigned long flen;
    unsigned char buf[1024], plain[1024];
    int ret, read_size, write_size;

    ret = 0;
    Rfd = open("cypher.txt", O_RDONLY);
    Wfd = open("plain.txt", O_RDWR);

    if((0 > Rfd) || (0 > Wfd)) {
        ret = -1;
        goto err;
    }

    printf("File opened\n");

    flen = lseek (Rfd, 0, SEEK_END);
    lseek (Rfd, 0, SEEK_SET);

    read_size = read(Rfd, buf, flen);
    if(read_size < 0) {
        ret = -2;
        goto err;
    }

    printf("File read\n");

    decrypt_AES128ECB("mybiggg_only_123", buf, plain, flen);

    printf("File decrypted\n");

    write_size = write(Wfd, plain, flen);
    if(write_size < 0) {
        ret = -3;
        goto err;
    }
  
    printf("File written\n");

err:
    close(Rfd);
    close(Wfd);

    printf("Done Error %d\n", ret);
    return ret;
}
